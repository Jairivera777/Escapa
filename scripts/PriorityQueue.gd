class_name PriorityQueue
extends RefCounted

class AlertEvent:
	var position: Vector3
	var priority: int
	var timestamp: int
	var description: String
	
	func _init(_pos: Vector3, _prio: int, _desc: String = "") -> void:
		position = _pos
		priority = _prio
		timestamp = Time.get_ticks_msec()
		description = _desc

var _heap: Array[AlertEvent] = []

func insert(pos: Vector3, priority: int, desc: String = "") -> void:
	var event = AlertEvent.new(pos, priority, desc)
	_heap.append(event)
	_sift_up(_heap.size() - 1)

func extract_max() -> AlertEvent:
	if is_empty():
		return null
	var max_event = _heap[0]
	var last_event = _heap.pop_back()
	if not is_empty():
		_heap[0] = last_event
		_sift_down(0)
	return max_event

func peek_max() -> AlertEvent:
	return _heap[0] if not is_empty() else null

func clear() -> void:
	_heap.clear()

func is_empty() -> bool:
	return _heap.is_empty()

func size() -> int:
	return _heap.size()

# --- Operaciones internas del Heap ---

func _is_higher_priority(a: AlertEvent, b: AlertEvent) -> bool:
	if a.priority != b.priority:
		return a.priority > b.priority
	# En caso de empate en prioridad, atiende el estímulo más reciente
	return a.timestamp > b.timestamp

func _sift_up(index: int) -> void:
	while index > 0:
		var parent = (index - 1) / 2
		if _is_higher_priority(_heap[index], _heap[parent]):
			_swap(index, parent)
			index = parent
		else:
			break

func _sift_down(index: int) -> void:
	var count = _heap.size()
	while true:
		var largest = index
		var left = 2 * index + 1
		var right = 2 * index + 2
		
		if left < count and _is_higher_priority(_heap[left], _heap[largest]):
			largest = left
		if right < count and _is_higher_priority(_heap[right], _heap[largest]):
			largest = right
			
		if largest != index:
			_swap(index, largest)
			index = largest
		else:
			break

func _swap(i: int, j: int) -> void:
	var temp = _heap[i]
	_heap[i] = _heap[j]
	_heap[j] = temp
