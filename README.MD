# Awaiter - Asynchronous Task Manager for Godot

A simple yet powerful asynchronous task management tool for Godot, designed to help you handle asynchronous operations more elegantly.

## Features

- **Wait for all tasks to complete** (`all`)
- **Wait for the first task to complete** (`race`)
- **Wait for a specified number of tasks to complete** (`some`)
- **Progress callback** for real-time task progress monitoring
- Supports **signals** and **asynchronous functions**

## Installation

1. Copy the `addons/awaiter` folder into your project.
2. You're ready to start using it!

## DEMO
Check out the demo file: [demo.gd](./demo.gd)

## Usage Examples

### Awaiter.all - Wait for All Tasks to Complete

Waits for all tasks to complete and returns their results in the order they were completed.

```gdscript
var results = await Awaiter.all([
    async_func1.bind(arg1, arg2), # Pass a Callable
    async_func2.bind(arg1, arg2),
    some_signal # Pass a Signal
])
# Results will be ordered by completion time (first completed task will be first in the array)
print(results) # [result1, result2, result3]
```

### Awaiter.race - Wait for the First Task to Complete

Returns the result of the fastest completing task.

```gdscript
var results = await Awaiter.race([
    task_function.bind("good morning", 0.1),
    task_function.bind("good night", 5.0),
])
print(results) # "good morning"
```

### Awaiter.some - Wait for a Specified Number of Tasks to Complete

Waits for a specified number of tasks to complete and returns their results.

```gdscript
var results = await Awaiter.some([
    task_function.bind("good morning", 1.0),
    task_function.bind("good night", 0.2),
    task_function.bind("good afternoon", 0.1),
    task_function.bind("good noon", 0.5),
], 2)
# Returns an array containing the first 2 completed tasks
print(results) # ["good afternoon", "good night"]
```

### Progress Callback

Provides real-time progress updates as tasks complete.

```gdscript
func progress_callback(completed_count, total):
    print(str(completed_count) + "/" + str(total))

await Awaiter.all({
    "task1": task_function.bind("good morning", 1.0),
    "task2": task_function.bind("good night", 0.2),
}, progress_callback)
```

### Task IDs

Allows you to assign IDs to tasks and retrieve results in a dictionary format.

```gdscript
var results = await Awaiter.all({
    "task1": task_function.bind("good morning", 1.0),
    "task2": task_function.bind("good night", 0.2),
}, progress_callback)
# Results will be a dictionary with task IDs as keys
print(results) # {"task1": "good morning", "task2": "good night"}
```

---

This tool simplifies asynchronous task management in Godot, making it easier to handle complex workflows with clean and readable code. Whether you're waiting for multiple tasks, racing them, or monitoring progress, Awaiter has you covered!
