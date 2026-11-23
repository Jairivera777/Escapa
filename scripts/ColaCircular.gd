class_name CircularQueue
extends RefCounted

class QNode:
	var data: Node3D
	var next: QNode = null
	
	func _init(_data: Node3D) -> void:
		data = _data

var head: QNode = null
var tail: QNode = null
var current: QNode = null
var size: int = 0

func enqueue(waypoint: Node3D) -> void:
	var new_node = QNode.new(waypoint)
	if is_empty():
		head = new_node
		tail = new_node
		new_node.next = head
		current = head
	else:
		tail.next = new_node
		tail = new_node
		tail.next = head
	size += 1

func get_next_waypoint() -> Node3D:
	if is_empty():
		return null
	var target = current.data
	current = current.next # Avanza circularmente
	return target

func peek_current() -> Node3D:
	return current.data if current != null else null

func is_empty() -> bool:
	return size == 0
