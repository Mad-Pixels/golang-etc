# Simple Ring Buffer Implementation

It can be use for:

**Fixed-size data management**, for high performance without dynamic memory allocation.

**FIFO systems**, where new data replaces old, keeping information current.

**Streamed media and network operations**, prioritizing continuity.

**Minimizing latency** in real-time and logging, accepting old data loss to maintain relevance.

```go
type RingBuffer struct {
	// Slice to store buffer data
	data []interface{}
	// Buffer capacity
	capacity int
	// Head index for reading
	head int
	// Tail index for writing
	tail int
	// Current buffer size
	size int
}

func NewRingBuffer(capacity int) *RingBuffer {
	return &RingBuffer{
		capacity: capacity,
		data: make(
			[]interface{},
			capacity,
		),
	}
}

// Push an item to the end of the buffer
func (rb *RingBuffer) Push(item interface{}) {
	if rb.size == rb.capacity {
		rb.head = (rb.head + 1) % rb.capacity
	} else {
		rb.size++
	}
	rb.data[rb.tail] = item
	rb.tail = (rb.tail + 1) % rb.capacity
}

// Pop and returns the oldest item
func (rb *RingBuffer) Pop() interface{} {
	if rb.size == 0 {
		return nil
	}
	item := rb.data[rb.head]
	rb.head = (rb.head + 1) % rb.capacity
	rb.size--
	return item
}

// Size returns the buffer size
func (rb *RingBuffer) Size() int {
	return rb.size
}
```