class_name Awaiter extends RefCounted

# 任务计数器类，用于追踪异步任务的完成状态
# Task counter class for tracking async task completion status
class Counter:
	# 任务完成信号，携带结果数据 | Task completion signal with result data
	signal completed(result)
	# 总任务数 | Total number of tasks
	var _total = 0
	# 结果列表 | Result list
	var _results = {}
	# 需要完成的任务数 | Number of tasks to complete
	var _required_count = INF
	# 进度回调函数 | Progress callback function
	var on_progress: Callable
	var is_completed = false
	var _is_array = false
	# 初始化计数器 | Initialize counter
	# @param total: 总任务数 | Total number of tasks
	# @param required_count: 需要完成的任务数 | Number of tasks to complete
	# @param progress_callback: 进度回调函数 | Progress callback function
	func _init(is_array, total, required_count := INF, progress_callback := Callable()):
		self._total = total
		self.on_progress = progress_callback
		self._required_count = required_count
		self._is_array = is_array
		self._results = [] if is_array else {}
	
	
	# 提交任务结果 | Submit task result
	# @param data: 任务结果数据 | Task result data
	func submit(task_name, data):
		if not is_completed:
			if _is_array:
				self._results.append(data)
			else:
				self._results[task_name] = data
			var completed_count = self._results.size()
			
			# 调用进度回调 | Call progress callback
			if on_progress.is_valid():
				on_progress.call(completed_count, _total)
			# 当达到所需数量时发出完成信号 | Emit completion signal when reaching required count
			if completed_count == self._total or completed_count == self._required_count:
				is_completed = true
				completed.emit()
				
	func get_data():
		return self._results

# 等待所有任务完成 | Wait for all tasks to complete
# @param tasks: 任务数组 | Array of tasks (signals, callables, or [callable, args...])
# @param progress_callback: 进度回调函数 | Progress callback function
static func all(tasks, progress_callback := Callable()):
	return await _process_tasks(tasks, INF, false, progress_callback)

# 等待第一个完成的任务 | Wait for the first completed task
# @param tasks: 任务数组 | Array of tasks
static func race(tasks) -> Variant:
	var result = await _process_tasks(tasks, 1, true)
	return result[0] if result else null

# 等待指定数量的任务完成 | Wait for specified number of tasks to complete
# @param tasks: 任务数组 | Array of tasks
# @param count: 需要等待的完成数量 | Number of tasks to wait for
# @param progress_callback: 进度回调函数 | Progress callback function
static func some(tasks, count: int, progress_callback := Callable()):
	count = mini(count, tasks.size())
	return await _process_tasks(tasks, count, false, progress_callback)

# 处理任务的内部方法 | Internal method for processing tasks
# @param tasks: 任务数组 | Array of tasks
# @param required_count: 需要完成的任务数 | Number of tasks to complete
# @param progress_callback: 进度回调函数 | Progress callback function
static func _process_tasks(tasks, required_count := INF, force_array=false, progress_callback := Callable()):
	var is_array = (tasks is Array) or force_array
	tasks = _to_callables(tasks)
	if tasks.is_empty():
		return [] if is_array else {}
		
	var counter = Counter.new(is_array, tasks.size(), required_count, progress_callback)
	for task_name in tasks:
		_async_task(task_name, tasks[task_name], counter)
	await counter.completed
	return counter.get_data()

# 等待单个任务的内部方法 | Internal method for awaiting a single task
# @param task: 目标任务 | Target task (signal or callable)
# @param counter: 计数器实例 | Counter instance
static func _async_task(task_name, task, counter: Counter):
	var result = await task.call()
	counter.submit(task_name, result)

# 将任务数组转换为可调用对象数组 | Convert task array to callable array
static func _to_callables(tasks) -> Dictionary:
	var callables = {}
	if tasks is Array:
		for index in tasks.size():
			var task = tasks[index]
			callables[index] = _to_callable(task)
	else:
		for task_name in tasks:
			var task = tasks[task_name]
			callables[task_name] = _to_callable(task)
	return callables

static func _to_callable(task):
	if task is Callable:
		return task
	elif task is Signal:
		return func(): return await task
