# Simple Ring Buffer Implementation

Ring buffers are optimally selected for:

1. **Fixed-size data management**, for high performance without dynamic memory
   allocation.
   - Example: Sensor data in embedded systems.
2. **FIFO systems**, where new data replaces old, keeping information current.
   - Example: Real-time stock price updates.
3. **Streamed media and network operations**, prioritizing continuity.
   - Example: Audio buffering in media players.
4. **Minimizing latency** in real-time and logging, accepting old data loss to
   maintain relevance.
   - Example: Latest system metrics for monitoring.

```go
type RingBuffer struct {
    data     []interface{} // Slice to store buffer data
    capacity int           // Buffer capacity
    head     int           // Head index for reading
    tail     int           // Tail index for writing
    size     int           // Current buffer size
}

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
```