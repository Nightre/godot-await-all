extends CanvasLayer

signal task_signal

func task_function(name: String, time: float):
	# Simulate an async task that returns after a specified delay
	await get_tree().create_timer(time).timeout
	return name
	
func _ready():
	# Set up a delayed signal that emits "hello!" after 1 second
	get_tree().create_timer(1).timeout.connect(func():
		task_signal.emit("hello!")
	)
	# Progress callback function to display task completion status
	var progress_callback = func(completed_count, total):
		print(str(completed_count) + "/" + str(total))
	
	
	
	print("\n=== Awaiter Simple Demo ===\n")
	print("== Awaiter.all ==")
	# Example 1: Wait for all array-based tasks to complete
	# results will be ordered by completion time (first completed task will be first in the array)
	print(await Awaiter.all([
		task_function.bind("good morning", 0.3),
		task_function.bind("good night", 0.5),
		get_tree().create_timer(0.2).timeout,
		task_signal,
	], progress_callback))
	
	print("== Awaiter.all with task id ==")
	# Example 2: Wait for all dictionary-based tasks to complete
	# Results will be returned as a dictionary with task IDs as keys
	print(await Awaiter.all({
		"task1": task_function.bind("good morning", 1.0),
		"task2": task_function.bind("good night", 0.2),
	}, progress_callback))
	
	print("== Awaiter.race ==")
	# Example 3: Wait for the first task to complete
	# Returns the result of the fastest completing task
	print(await Awaiter.race([
		task_function.bind("good morning", 1.0),
		task_function.bind("good night", 0.3),
	]))
	
	print("== Awaiter.some with task id ==")
	# Example 4: Wait for any 2 tasks to complete with task IDs
	# Returns a dictionary containing the first 2 completed tasks
	print(await Awaiter.some({
		"task1": task_function.bind("good morning", 1.0),
		"task2": task_function.bind("good night", 0.2),
		"task3": task_function.bind("good afternoon", 0.3),
		"task4": task_function.bind("good noon", 0.5),
	}, 2))
	
	print("== Awaiter.some ==")
	# Example 5: Wait for any 2 tasks to complete from array
	# Returns an array containing the first 2 completed tasks
	print(await Awaiter.some([
		task_function.bind("good morning", 1.0),
		task_function.bind("good night", 0.2),
		task_function.bind("good afternoon", 0.1),
		task_function.bind("good noon", 0.5),
	], 2))
	
	print("\n=== Demo Completed ===")
