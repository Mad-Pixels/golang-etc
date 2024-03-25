# Simple Ring Buffer Implementation.

Ring buffers are the optimal selection for:

1. **Fixed-size data management**, ensuring high performance without dynamic memory allocation.
   * *Example: Managing sensor data in embedded systems.*
2. **FIFO systems**, where new data replaces old, keeping information current.
   * *Example: Real-time stock price updates.*
3. **Streamed media and network operations**, where continuity is crucial.
   * *Example: Audio playback buffering in media players.*
4. **Minimizing latency** in real-time systems and logging, accepting old data loss to maintain relevance.
   * *Example: Collecting the latest system metrics for monitoring.*

```go
package main

import "fmt"

// RingBuffer object
type RingBuffer struct {
	data     []interface{} // Slice to store buffer data
	capacity int           // Capacity of the buffer
	head     int           // Index for the head of the buffer, where data is read
	tail     int           // Index for the tail of the buffer, where data is written
	size     int           // Current size of the buffer
}

// NewRingBuffer creates and returns a new instance of a ring buffer with a given size
func NewRingBuffer(capacity int) *RingBuffer {
	return &RingBuffer{
		data:     make([]interface{}, capacity),
		capacity: capacity,
	}
}

// Push adds an item to the end of the buffer
func (rb *RingBuffer) Push(item interface{}) {
	if rb.size == rb.capacity {
		// If the buffer is full, overwrite the oldest element (overwrite head)
		rb.head = (rb.head + 1) % rb.capacity
	} else {
		rb.size++
	}
	// Insert the item at the tail position and move the tail forward
	rb.data[rb.tail] = item
	rb.tail = (rb.tail + 1) % rb.capacity
}

// Pop removes and returns the oldest item from the buffer
func (rb *RingBuffer) Pop() interface{} {
	if rb.size == 0 {
		// If the buffer is empty, return nil
		return nil
	}
	// Retrieve the item from the head
	item := rb.data[rb.head]
	// Move the head forward and decrease the size
	rb.head = (rb.head + 1) % rb.capacity
	rb.size--
	return item
}

// Size returns the current size of the buffer
func (rb *RingBuffer) Size() int {
	return rb.size
}

func main() {
	rb := NewRingBuffer(5) // Create a ring buffer with a capacity of 5 items

	// Add items to the buffer
	rb.Push(1)
	rb.Push(2)
	rb.Push(3)
	rb.Push(4)
	rb.Push(5)
	fmt.Println("Initial buffer filled with elements 1 to 5")

	// Exceed capacity to demonstrate overwriting
	rb.Push(6)
	fmt.Println("Added element 6, overwriting the oldest element (1)")
	fmt.Printf("Oldest element now (should be 2): %v\n", rb.Pop())

	// Continue adding elements, showing the overwrite process
	rb.Push(7)
	fmt.Println("Added element 7, continuing overwrite process")
	fmt.Printf("Oldest element now (should be 3): %v\n", rb.Pop())

	// Show current buffer size
	fmt.Printf("Current buffer size after some pops: %d\n", rb.Size())

	// Pop remaining elements to see the state of the buffer
	fmt.Println("Popping remaining elements:")
	fmt.Println(rb.Pop()) // Should print 4
	fmt.Println(rb.Pop()) // Should print 5
	fmt.Println(rb.Pop()) // Should print 6, as it was added after the buffer was filled initially

	// Final buffer size after clearing some elements
	fmt.Printf("Final buffer size: %d\n", rb.Size())
}

```
