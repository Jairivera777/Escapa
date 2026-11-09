extends Control
@export var jugador : CharacterBody3D
@onready var contenedorSlots : HBoxContainer = $MarginContainer/HBoxContainer
var slots : Array = []
var slotActivo : int = 0
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
	for i in range(slots.size()):
		slot = slots[i]
		item = jugador.inventario[i]
		if i == slotActivo:
			slot.modulate = Color.GREEN
		else:
			slot.modulate = Color.WHITE
func _process(delta: float) -> void:
	if not jugador:
		return
	actualizarSlots()
