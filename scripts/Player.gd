extends CharacterBody3D

var snap_vector : Vector3 = Vector3.DOWN
var speed : float

@export_group("Movement variables")
@export var walk_speed : float = 2.0
@export var run_speed : float = 5.0
@export var jump_strength : float = 15.0
@export var gravity : float = 50.0
@export var sensibilidad : float = 0.002 
@export var min_pitch : float = deg_to_rad(-80.0) 
@export var max_pitch : float = deg_to_rad(80.0)  

@onready var player_mesh : Node3D = $Mesh
@onready var camera = $Mesh/Armature/Skeleton3D/BoneAttachment3D/Camera3D
# Conectamos directamente el reproductor, ignorando el árbol
@onready var anim_player = $AnimationPlayer 

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensibilidad)
		camera.rotate_x(event.relative.y * sensibilidad)
		camera.rotation.x = clamp(camera.rotation.x, min_pitch, max_pitch)
		camera.rotation.z = 0
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	var input_dir : Vector3 = Vector3.ZERO
	input_dir.x = Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	input_dir.z = Input.get_action_strength("abajo") - Input.get_action_strength("arriba")
	
	velocity.y -= gravity * delta
	
	var move_direction := (global_transform.basis * Vector3(input_dir.x, 0, input_dir.z)).normalized()
	
	if Input.is_action_pressed("correr"):
		speed = run_speed
	else:
		speed = walk_speed
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	
	# Mantenemos la malla rotada correctamente
	#player_mesh.rotation.y = 0
	
	var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("ui_accept")
	if is_jumping:
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN
	
	apply_floor_snap()
	move_and_slide()
	animate()

func animate():
	var velocidad_horizontal = Vector2(velocity.x, velocity.z).length()
	var nueva_animacion = "Idle"
	
	if is_on_floor():
		if velocidad_horizontal > 0.1:
			if speed == run_speed:
				nueva_animacion = "Run"
			else:
				nueva_animacion = "Walk"
	else:
		nueva_animacion = "Air"
	
	# El radar: esto imprimirá en consola lo que realmente pasa
	print("El código pide: ", nueva_animacion, " | El reproductor tiene: ", anim_player.current_animation)
	
	# Solo reproducimos si la animación cambió
	if anim_player.current_animation != nueva_animacion:
		anim_player.play(nueva_animacion, 0.2)
