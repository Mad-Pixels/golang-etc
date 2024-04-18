# sync.Pool: optimizing object reuse
The `sync.Pool` in Go optimizes application performance by managing object reuse, reducing the burden on memory allocation and garbage collection. 

It's important to note that `sync.Pool` **doesn't guarantee long-term object retention within the pool**, as objects can be cleared during garbage collection.

`sync.Pool` provides a mechanism for temporary object storage:  **New:** A function for creating a new object when the pool is empty.  **Get:** Retrieves an object from the pool.  **Put:** Returns an object to the pool for reuse.
```go
type Task struct {
    ID   int
    Name string
}

func main() {
	var pool sync.Pool
	
	// define pool
	pool.New = func() interface{} {
        return &Task{}
	}
	
	// get object from pool 
	task := pool.Get().(*Task)

	// use object 
	task.ID = 1
	task.Name = "Example"
	fmt.Printf(
		"Task ID: %d, Name: %s\n", 
		task.ID, 
		task.Name,
	)

	// cleanup before put back 
	task.ID = 0
	task.Name = ""
	pool.Put(task)
}
```
**Initialization:** `New()` initiates the creation of Task objects.  **Usage and Return:** Objects are used, then their data is cleared before returning them to the pool to avoid data leaks.

## Managing Objects with Variable Size
The example with `bytes.Buffer` illustrates how to manage objects whose internal capacity can change depending on the volume of processed data.
```go
var bufferPool = sync.Pool{
	New: func() interface{} {
		return new(bytes.Buffer)
	},
}

func processRequest(data string) {
	buf := bufferPool.Get().(*bytes.Buffer)
	defer bufferPool.Put(buf)

	buf.WriteString(data)
	fmt.Println(buf.String())
	buf.Reset()
}

func main() {
	processRequest("Hello, World!")
	processRequest("long message")
}
```
**In the current implementation, there are a number of issues**

In our example, an object with `capacity = 0` will be allocated. 
```go
return new(bytes.Buffer)
```

When we write data to the buffer using `buf.WriteString(data)`, the internal capacity of the object **grows**.
```go
buf.WriteString(data)
```
**Even when using a pool, we still allocate memory.**

When we call `buf.Reset()`, we remove the data, but the **object's capacity remains unchanged**, and we place this object back into the pool. 
```go
func main() {
	b := new(bytes.Buffer)
	fmt.Println(b.Len(), b.Cap()) 
	// 0 0
	
	b.WriteString("long message")
	fmt.Println(b.Len(), b.Cap()) 
	// 12 64

	b.Reset()
	fmt.Println(b.Len(), b.Cap())
	// 0 64
}
```
This means that even though we have cleared the data, the object will still occupy all the allocated space beneath it.

When returning such objects back to the pool, we may encounter a situation where we store objects of the same type, but each object may occupy a different amount of memory, which could lead to critical overconsumption at certain times.

### Managing Object Capacity
**Initialize with Expected Capacity:** To avoid dynamic memory expansion, initialize the object with the expected capacity.
```go
var bufferPool = sync.Pool{
    New: func() interface{} {
		return bytes.NewBuffer(
			make([]byte, 0, 1024), 
		)
    },
}
```
**Don't Return Large Objects:** In exceptional cases, consider not returning objects to the pool to maintain size homogeneity.
```go
if buf.Cap() <= 512 {
  bufferPool.Put(buf)
}
```
**Compress Capacity:** If the capacity significantly exceeds the used volume, create a new buffer with smaller capacity and copy the data.
```go
if buf.Cap() > 3*buf.Len() {
  newBuf := bytes.NewBuffer(
    make([]byte, 0, buf.Len()),
  )
  newBuf.Write(buf.Bytes())
  buf = newBuf
}
bufferPool.Put(buf)
```