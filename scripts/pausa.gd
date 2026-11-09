extends Control

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		menuPausa()
func menuPausa() -> void:
	var pausa = not get_tree().paused
	get_tree().paused = pausa
	visible = pausa
	if pausa:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		release_focus()

func continuar() -> void:
	menuPausa()
func salir() -> void:
	get_tree().paused = false
	get_tree().quit()
