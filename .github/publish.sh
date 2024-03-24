#!/bin/bash

validate_env() {
  if [ -z "${!1}" ]; then
    printf "${RED}%s\nVariable $1 is empty.\n%s\n${NC}" "$HR" "$HR"
    exit 1
  fi
}

publish_content() {
  local content="$1"
  local message="$2"

  if [ -z "$content" ]; then
    printf "${YELLOW}%s\n${NC}" "$message"
  else
    for dir in $content; do
      if ! "${ROOT_DIR}/${POSTIFY_NAME}" tg-send \
        --from "${ROOT_DIR}/${dir}" \
        --bot-token "${CONTENT_TG_TOKEN}" \
        --chat-id "${CONTENT_TG_CHAT}";
      then
        echo "${RED}Execution failed, exit 1${dir}.${NC}" && exit 1
      fi
    done
  fi
}

############################################################
# Pre-Execution Checks                                     #
############################################################
ARCH=$(uname -m)
OS=$(uname -s)

if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
fi

if [ "$ARCH" != "amd64" ] && [ "$ARCH" != "arm64" ]; then
    echo "Error: Unsupported architecture ${ARCH}. Only amd64 and arm64 are supported."
    exit 1
fi

if [ "$OS" != "Linux" ] && [ "$OS" != "Darwin" ]; then
    echo "Error: Unsupported operating system ${OS}. Only Linux and Darwin are supported."
    exit 1
fi

CONTENT_TG_TOKEN=${TG_TOKEN}
validate_env "CONTENT_TG_TOKEN"

CONTENT_TG_CHAT=${TG_CHAT}
validate_env "CONTENT_TG_CHAT"

STATIC_BUCKET=${AWS_BUCKET}
validate_env "STATIC_BUCKET"

############################################################
# Define Global Variables                                  #
############################################################
ROOT_DIR=$(git rev-parse --show-toplevel)

POSTIFY_VERSION="0.0.1"
POSTIFY_NAME="postify"
POSTIFY_URL="https://github.com/Mad-Pixels/go-postify/releases/download/v${POSTIFY_VERSION}/${POSTIFY_NAME}-${OS}-${ARCH}"

STATIC_NAME="golang-etc-frontend"
STATIC_SOURCE_GIT_URL="https://github.com/Mad-Pixels/${STATIC_NAME}.git"

GITHUB_BOT_USER="github-actions[bot]"
GITHUB_BOT_MAIL="github-actions[bot]@users.noreply.github.com"
GITHUB_COMMIT_MSG="[🤖]: update content meta-info"
GITHUB_COMMIT_BRANCH="main"

CONTENT_ALL=$(cd "${ROOT_DIR}" && ls -d */ || echo "")
CONTENT_NEW=$(git diff --name-only HEAD^ HEAD --diff-filter=A | grep -v '^\.' | xargs -n 1 dirname | sort -u | grep -v '/\.' | grep -v '^.$' | sort -u)
CONTENT_CHANGED=$(git diff --name-only HEAD^ HEAD --diff-filter=M | grep -v '^\.' | xargs -n 1 dirname | sort -u | grep -v '/\.' | sort -u | grep -v '^.$')

HR=$(printf '%*s\n' "80" '' | tr ' ' '=')
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

############################################################
# Download Postify                                         #
############################################################
echo -e "\n"
echo -e "${GREEN}Downloading Postify.${NC}"
echo -e "${YELLOW}$HR${NC}\n"

if curl -L "${POSTIFY_URL}" -o "${ROOT_DIR}/${POSTIFY_NAME}"; then
  chmod +x "${ROOT_DIR}/${POSTIFY_NAME}"
else
  echo "${RED}Failed to download Postify.${NC}" && exit 1
fi

############################################################
# Publish To Telegram                                      #
############################################################
echo -e "\n"
echo -e "${GREEN}Publish To Telegram.${NC}"
echo -e "${YELLOW}$HR${NC}\n"

publish_content "${CONTENT_CHANGED}" "changed posts not found"
publish_content "${CONTENT_NEW}" "new posts not found"

############################################################
# Generate Static Data                                     #
############################################################
echo -e "\n"
echo -e "${GREEN}Generate Static Sources.${NC}"
echo -e "${YELLOW}$HR${NC}\n"

echo -e "${GREEN}Download sources.${NC}"
if cd "${ROOT_DIR}" && git clone "${STATIC_SOURCE_GIT_URL}"; then
  echo -e "${GREEN}Start generate static data.${NC}"

  for dir in $CONTENT_ALL; do
    if ! ${ROOT_DIR}/${POSTIFY_NAME} html-content \
      --with-router "${ROOT_DIR}/${STATIC_NAME}/src/routes/content/router.json" \
      --with-tmpl "${ROOT_DIR}/${STATIC_NAME}/assets/templates/content.svelte" \
      --to "${ROOT_DIR}/${STATIC_NAME}/src/routes/content/${dir}" \
      --with-assets "${ROOT_DIR}/${STATIC_NAME}/assets/content" \
      --from "${ROOT_DIR}/${dir}" \
      --with-name +page.svelte;
    then
      echo "${RED}Execution failed, exit 1${NC}" && exit 1
    fi
  done
else
  echo "${RED}Execution failed, exit 1${NC}" && exit 1
fi

############################################################
# Build Static                                             #
############################################################
echo -e "\n"
echo -e "${GREEN}Build Static.${NC}"
echo -e "${YELLOW}$HR${NC}\n"

if cd "${ROOT_DIR}/${STATIC_NAME}" && npm install --silent && npm run build; then
  echo -e "${GREEN}Upload static site.${NC}"

  if ! aws s3 sync ./build/ s3://"${AWS_BUCKET}--prd" --delete; then
    echo "${RED}Execution failed, exit 1${NC}" && exit 1
  fi
else
  echo "${RED}Execution failed, exit 1${NC}" && exit 1
fi

############################################################
# APPLY CHANGES                                            #
############################################################
echo -e "\n"
echo -e "${GREEN}Apply Changes.${NC}"
echo -e "${YELLOW}$HR${NC}\n"

cd "${ROOT_DIR}" || exit 1
# shellcheck disable=SC2115
rm -rf "${ROOT_DIR}/${STATIC_NAME}" "${ROOT_DIR}/${POSTIFY_NAME}"

git config --global user.name "${GITHUB_BOT_USER}"
git config --global user.email "${GITHUB_BOT_MAIL}"

git add .
if git commit -m "${GITHUB_COMMIT_MSG}"; then
  git push origin "${GITHUB_COMMIT_BRANCH}"
else
  echo "${YELLOW}No changes to commit.${NC}"
fi

echo -e "\n"
echo -e "${GREEN}FINISH.${NC}"
echo -e "${YELLOW}$HR${NC}\n"
exit 0
