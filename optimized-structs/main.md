# Struct optimization

In Golang, structures feature a phenomenon known as "**padding**", which is associated with the alignment of data in memory. During the compilation of programs, the compiler attempts to organize the data in such a manner that access to it is as efficient as possible. This means that sometimes unused bytes (*so-called "padding"*) are added between the fields of a structure to ensure that the starting addresses of the fields adhere to specific alignment rules.

To optimize the sizes of structures in Golang, one should adhere to the following rule:

**Arrange the fields within the structure in descending order of their size**.

```go
// for x64
type Example struct {
    // pointer, 8 bytes
    ptr *int64 
  
    // slice, 8 bytes
    slice []int
  
    // chan 8 bytes
    channel chan bool
  
    // map 8 bytes
    mapField map[string]int
  
    // int64 8 bytes
    int64Field int64
  
    // int32 4 bytes
    int32Field int32 
  
    // byte 1 byte
    byteField1 byte
}
```

When the fields of a structure are ordered by decreasing size, there is a reduced likelihood that unused bytes will need to be inserted between them for alignment. This increases the data density in memory and reduces the overall size of the structure.
