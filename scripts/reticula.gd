extends Control
@export var color = Color.WHITE
@export var radio : float = 3

func _draw() -> void:
	var centro = size / 2
	draw_circle(centro, radio, color)

func _ready() -> void:
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
