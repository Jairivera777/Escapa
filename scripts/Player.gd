extends CharacterBody3D

var snap_vector : Vector3 = Vector3.DOWN
var speed : float

@export_group("Movement variables")
@export var walk_speed : float = 2.0
@export var run_speed : float = 5
@export var jump_strength : float = 6
@export var gravity : float = 20
@export var sensibilidad : float = 0.002 
@export var min_pitch : float = deg_to_rad(-80.0) 
@export var max_pitch : float = deg_to_rad(80.0)  

@export_category("Inventario")
@export var tamano : int = 9
var inventario : Array = [null, null, null, null, null, null, null, null, null]

@onready var player_mesh : Node3D = $Mesh
@onready var camera = $Mesh/Armature/Skeleton3D/BoneAttachment3D/Camera3D
@onready var anim_player = $AnimationPlayer 
@onready var rayCast = $Mesh/Armature/Skeleton3D/BoneAttachment3D/Camera3D/RayCast3D
var tiempo : float = 0
var puerta : Node3D = null
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rayCast.add_exception(self)
	inventario.resize(tamano)
	inventario.fill(null)
func agregarInventario(nombreItem : String, imagen : Texture2D) -> bool:
	for i in range (inventario.size()):
		if inventario[i] == null:
			inventario[i] = {
				"nombre" = nombreItem,
				"imagen" = imagen
			}
			return true
	return false
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensibilidad)
		camera.rotate_x(event.relative.y * sensibilidad)
		camera.rotation.x = clamp(camera.rotation.x, min_pitch, max_pitch)
		camera.rotation.z = 0
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta : float):
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
	interactuarObjeto(delta)
func interactuarObjeto(delta : float):
	rayCast.force_raycast_update()
	var objeto = null
	if rayCast.is_colliding():
		objeto = rayCast.get_collider()
		if objeto != null:
			var puertaValida = objeto and objeto.is_in_group("puertas") and objeto.has_method("interactuar")
			if Input.is_action_just_pressed("Interactuar") and objeto.is_in_group("Items") and objeto.has_method("interactuar"):
				var seGuardo = objeto.interactuar(self)
				if !seGuardo:
					$CanvasLayer/hotBar.mostrarMensajeLleno()
			if Input.is_action_just_pressed("Interactuar") and  puertaValida:
				puerta = objeto
				tiempo = 0
			if Input.is_action_pressed("Interactuar") and puerta != null:
				tiempo += delta
				if tiempo >= 0.25:
					puerta.interactuar(true)
					puerta = null
			if Input.is_action_just_released("Interactuar"):
				if puerta != null:
					if tiempo < 0.25:
						puerta.interactuar(false)
					puerta = null
					tiempo = 0.0
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
	
	if anim_player.current_animation != nueva_animacion:
		anim_player.play(nueva_animacion, 0.2)
