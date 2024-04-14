# Force stop with Must func
In Go, there is an informal rule to use the **Must** function in certain situations, despite its ability to force stop the app.

**Must is used where errors should not occur, and if they do, it triggers a panic to immediately exit the app.**  This is particularly relevant during critical initializations, such as setting up global variables and database connections, as well as in testing to quickly interrupt when serious errors are detected.
```go
package main

import (
    "database/sql"
    "fmt"
    "log"

    _ "github.com/lib/pq"
)

func MustConnectDB(sources string) *sql.DB {
    db, err := sql.Open(
        "postgres",
        sources,
    )
    if err != nil {
        log.Panicf(
            "Failed connect: %v",
            err,
        )
    }
    if err = db.Ping(); err != nil {
        log.Panicf(
            "Failed to ping db: %v",
            err,
        )
    }
    return db
}

func main() {
    source := fmt.Sprintf(
        "%s %s %s %s %s",
        "host=localhost",
        "user=postgres",
        "password=pass",
        "dbname=exampledb",
        "sslmode=disable",
    )
    db := MustConnectDB(source)
    defer db.Close()
}
```