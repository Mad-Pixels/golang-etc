# Manage build by tags

In Go, the "**-tags**" option in the _go build_ command allows you to specify which parts of the code will be compiled using special tags. These tags control conditional compilation, helping to include or exclude code for different environments, such as development and production or for different platforms.

Let say that you want to differentiate logging detail levels between the test and production environments. Using the test and prod tags, you create two files:

### logging_test.go
```go
//go:build test

package logging

// test logger
func MyLogger() { ... }
```

### logging_prod.go
```go
//go:build prod

package logging

// prod logger
func MyLogger() { ... }
```

## Compilation for each environment:
* go build -tags test
* go build -tags prod

## Tags:
Standard tags include: **linux**, **darwin**, **windows**, **amd64**, **arm64**, **cgo**.

Custom tags can be like: **release**, **test**, **prod**, **what-ever-you-want**.

Supported operators: **&&** (AND), **||** (OR) and **!** (NOT).

### linux_amd64.go
```go
// For Go 1.17 and above
//go:build linux && amd64 && !debug

// For Go below 1.17
// +build linux,amd64,!debug
```

This specifies compilation only for **Linux** on **amd64** without **debug** code.
