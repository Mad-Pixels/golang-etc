# Why is "_ struct{}" needed?

In short: **it's a matter of style**.

Essentially, the use of the "*_ struct{}*" construction does not affect the functionality of the structure. Its only purpose is to prevent the initialization of a new structure with unnamed parameters, which in some cases can improve the readability of the code.

```go
type MyStruct struct {
    Foo string
    Bar int
    _   struct{}
}

// compile error:
// too few values in struct literal of type ...
s := MyStruct{"foo", 10}

// ok, no errors
s := MyStruct{Foo: "foo", Bar: 10}
```

However, the restriction with named literals can be bypassed like this (works only within the same scope):

```go
// ok, no errors
s := MyStruct{"foo", 10, struct{}{}} 
```

If the structure is in another package, initializing it with "*struct{}{}*" will lead to a compilation error:

```go
// sample/sample.go
type MyStruct struct {
    Foo string
    Bar int
    _   struct{}
}

// main.go
import "{{ module_name }}/sample"

// compile error:
// implicit assignment to unexported field _ in struct literal 
s := sample.MyStruct{"foo", 10, struct{}{}}

// ok, no errors
s := sample.MyStruct{Foo: "foo", Bar: 10}
```

Summarizing, the empty struct is not mandatory to use, although sometimes it can indeed improve the readability of the code.
