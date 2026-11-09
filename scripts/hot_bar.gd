extends Control
@export var jugador : CharacterBody3D
@onready var contenedorSlots : HBoxContainer = $VBoxContainer/MarginContainer/HBoxContainer
@onready var label : Label = $VBoxContainer/NombreItem
var slots : Array = []
var slotActivo : int = 0
var mensajeTemporal : bool = false
func _ready() -> void:
	if not jugador:
		jugador = get_tree().get_first_node_in_group("jugador")
	await get_tree().process_frame
	slots = contenedorSlots.get_children()
	if slots.size() > 0:
		actualizarSlots()
func actualizarSlots() -> void:
	var slot
	var item
	var imagen : TextureRect
	for i in range(slots.size()):
		slot = slots[i]
		imagen = slot.get_node("imagen")
		item = jugador.inventario[i] if i < jugador.inventario.size() else null
		if item != null:
			imagen.texture = item.imagen
			imagen.modulate = Color(1, 1, 1, 1)
		else:
			imagen.texture = null
			imagen.modulate = Color(1, 1, 1, 0)
		if i == slotActivo:
			slot.modulate = Color.GREEN
		else:
			slot.modulate = Color.WHITE
	var itemActivo = jugador.inventario[slotActivo] if slotActivo < jugador.inventario.size() else null
	if itemActivo != null:
		label.text = itemActivo.nombre
	else:
		label.text = ""
func _process(delta: float) -> void:
	if not jugador:
		return
	if !mensajeTemporal:
		var itemActivo = jugador.inventario[slotActivo] if slotActivo < jugador.inventario.size() else null
		if itemActivo != null:
			label.text = itemActivo.nombre
		else:
			label.text = ""
	actualizarSlots()
func _unhandled_input(event: InputEvent) -> void:
	var nombre
	for i in range(9):
		nombre = "slot " + str(i+1)
		if Input.is_action_just_pressed(nombre):
			if i < slots.size():
				slotActivo = i
				actualizarSlots()
				break
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			slotActivo += 1
			if slotActivo > 8:
				slotActivo = 0
			actualizarSlots()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			slotActivo -= 1
			if slotActivo < 0:
				slotActivo = slots.size()-1
			actualizarSlots()
func mostrarMensajeLleno() -> void:
	mensajeTemporal = true
	label.text = "¡Inventario Lleno!"
	await get_tree().create_timer(5).timeout
	mensajeTemporal = false
	actualizarSlots()
