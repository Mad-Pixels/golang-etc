```go
package main

import "fmt"

// RingBuffer object
type RingBuffer struct {
    data     []interface{} // Slice to store buffer data
    capacity int           // Buffer capacity
    head     int           // Head index for reading
    tail     int           // Tail index for writing
    size     int           // Current buffer size
}

// NewRingBuffer creates a new ring buffer instance
func NewRingBuffer(capacity int) *RingBuffer {
    return &RingBuffer{
        data:     make([]interface{}, capacity),
        capacity: capacity,
    }
}

// Push adds an item to the end of the buffer
func (rb *RingBuffer) Push(item interface{}) {
    if rb.size == rb.capacity {
        // Overwrite the oldest element if full
        rb.head = (rb.head + 1) % rb.capacity
    } else {
        rb.size++
    }
    rb.data[rb.tail] = item
    rb.tail = (rb.tail + 1) % rb.capacity
}

// Pop removes and returns the oldest item
func (rb *RingBuffer) Pop() interface{} {
    if rb.size == 0 {
        return nil // Return nil if empty
    }
    item := rb.data[rb.head]
    rb.head = (rb.head + 1) % rb.capacity
    rb.size--
    return item
}

// Size returns the current buffer size
func (rb *RingBuffer) Size() int {
    return rb.size
}

func main() {
    rb := NewRingBuffer(5) // Create a buffer with 5 items capacity

    // Populate the buffer
    rb.Push(1)
    rb.Push(2)
    rb.Push(3)
    rb.Push(4)
    rb.Push(5)
    fmt.Println("Buffer filled with elements 1 to 5")

    // Demonstrate overwriting
    rb.Push(6)
    fmt.Println("Added element 6, overwriting the oldest (1)")
    fmt.Printf("Oldest now (should be 2): %v\n", rb.Pop())

    // Continue overwriting
    rb.Push(7)
    fmt.Println("Added element 7, overwriting continues")
    fmt.Printf("Oldest now (should be 3): %v\n", rb.Pop())

    // Display current buffer size
    fmt.Printf("Buffer size after pops: %d\n", rb.Size())

    // Pop remaining elements
    fmt.Println("Popping remaining elements:")
    fmt.Println(rb.Pop()) // Should print 4
    fmt.Println(rb.Pop()) // Should print 5
    fmt.Println(rb.Pop()) // Should print 6

    // Final buffer size
    fmt.Printf("Final buffer size: %d\n", rb.Size())
}
```