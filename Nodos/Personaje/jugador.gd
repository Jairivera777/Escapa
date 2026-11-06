extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SPEED_RUN = 8.5
@export var mouse_sensitivity: float = 0.003 # Sensibilidad del ratón
@onready var head: Node3D = $Head # Asegúrate de que el nombre coincida con tu nodo Node3D
@onready var camera: Camera3D = $Head/Camera3D
var rotation_x: float = 0.0
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _unhandled_input(event: InputEvent) -> void:
	# Detecta el movimiento del mouse
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# 1. Rotar el cuerpo entero del personaje horizontalmente (Eje Y)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# 2. Rotar la cabeza/cámara verticalmente (Eje X)
		rotation_x -= event.relative.y * mouse_sensitivity
		# Limitamos la rotación para que el jugador no pueda mirar "boca abajo" (90 grados)
		rotation_x = clamp(rotation_x, deg_to_rad(-85), deg_to_rad(85))
		head.rotation.x = rotation_x
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var actual_speed = SPEED
	if Input.is_action_pressed("correr") and not Input.is_action_pressed("abajo"):
		actual_speed = SPEED_RUN
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * actual_speed
		velocity.z = direction.z * actual_speed
	else:
		velocity.x = move_toward(velocity.x, 0, actual_speed)
		velocity.z = move_toward(velocity.z, 0, actual_speed)

	move_and_slide()
