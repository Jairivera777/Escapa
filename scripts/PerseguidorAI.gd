class_name PerseguidorAI
extends CharacterBody3D

@export_category("References")
@export var nav_agent: NavigationAgent3D
@export var player: Node3D

@export_category("AI Settings")
@export var move_speed_patrol: float = 2.0
@export var move_speed_investigate: float = 3.2
@export var move_speed_chase: float = 4.6
@export var rotation_speed: float = 10.0
@export var view_distance: float = 12.0
@export var view_angle_degrees: float = 45.0

@export_category("Patrol Waypoints")
@export var patrol_markers: Array[Node3D] = []

enum AIState { PATROL, INVESTIGATE, CHASE }
var current_state: AIState = AIState.PATROL

# Instancias de las estructuras de datos
var patrol_queue: CircularQueue = CircularQueue.new()
var alert_pq: PriorityQueue = PriorityQueue.new()

var current_alert: PriorityQueue.AlertEvent = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("perseguidor")
	
	if not nav_agent:
		nav_agent = $NavigationAgent3D
	
	# Poblar la cola circular con los marcadores asignados en el editor
	for marker in patrol_markers:
		if marker != null:
			patrol_queue.enqueue(marker)
			
	if not patrol_queue.is_empty():
		_advance_patrol()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# 1. Detección visual directa (máxima prioridad absoluta)
	if _can_see_player():
		if current_state != AIState.CHASE:
			print("[PerseguidorAI] ¡Jugador avistado! Iniciando persecución.")
		current_state = AIState.CHASE
		current_alert = null
		alert_pq.clear()

	# 2. Máquina de estados
	match current_state:
		AIState.PATROL:
			_handle_patrol_state()
		AIState.INVESTIGATE:
			_handle_investigate_state()
		AIState.CHASE:
			_handle_chase_state()

	# 3. Ejecución del movimiento
	if not nav_agent.is_navigation_finished():
		var next_path_position: Vector3 = nav_agent.get_next_path_position()
		var direction: Vector3 = (next_path_position - global_position).normalized()
		
		var speed = move_speed_patrol
		if current_state == AIState.INVESTIGATE:
			speed = move_speed_investigate
		elif current_state == AIState.CHASE:
			speed = move_speed_chase
			
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		if direction.length() > 0.1:
			var target_rotation = atan2(-velocity.x, -velocity.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed_patrol)
		velocity.z = move_toward(velocity.z, 0, move_speed_patrol)

	move_and_slide()

# --- LÓGICA DE ESTADOS ---

func _handle_patrol_state() -> void:
	if not alert_pq.is_empty():
		_start_next_investigation()
		return
		
	if not patrol_queue.is_empty() and nav_agent.is_navigation_finished():
		_advance_patrol()

func _handle_investigate_state() -> void:
	var top_alert = alert_pq.peek_max()
	if top_alert != null and current_alert != null:
		if top_alert.priority > current_alert.priority:
			print("[PerseguidorAI] Interrumpiendo investigación por evento más urgente: ", top_alert.description)
			_start_next_investigation()
			return

	if nav_agent.is_navigation_finished():
		print("[PerseguidorAI] Punto revisado: ", current_alert.description if current_alert else "Desconocido")
		current_alert = null
		
		if not alert_pq.is_empty():
			_start_next_investigation()
		else:
			print("[PerseguidorAI] Sin más alertas. Volviendo a ruta de patrulla circular.")
			current_state = AIState.PATROL
			_advance_patrol()

func _handle_chase_state() -> void:
	if not player:
		current_state = AIState.PATROL
		return
		
	nav_agent.set_target_position(player.global_position)
	
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > (view_distance * 1.5) and not _can_see_player():
		print("[PerseguidorAI] Jugador perdido de vista. Registrando última posición conocida.")
		register_stimulus(player.global_position, 100, "Última posición vista del jugador")
		_start_next_investigation()

# --- GESTIÓN DE COLAS ---

func _advance_patrol() -> void:
	var next_marker = patrol_queue.get_next_waypoint()
	if next_marker:
		nav_agent.set_target_position(next_marker.global_position)

func _start_next_investigation() -> void:
	current_alert = alert_pq.extract_max()
	if current_alert != null:
		current_state = AIState.INVESTIGATE
		nav_agent.set_target_position(current_alert.position)
		print("[PerseguidorAI] Investigando -> ", current_alert.description, " (Prioridad: ", current_alert.priority, ")")

# --- MÉTODO PÚBLICO PARA ESTÍMULOS (RUIDO E INTERACCIONES) ---

func register_stimulus(world_position: Vector3, priority: int, description: String = "Ruido") -> void:
	if current_state == AIState.CHASE:
		return
	alert_pq.insert(world_position, priority, description)
	
	if current_state == AIState.PATROL:
		_start_next_investigation()

# --- VISIÓN ---

func _can_see_player() -> bool:
	if not player:
		return false
		
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > view_distance:
		return false
		
	var direction_to_player = (player.global_position - global_position).normalized()
	var forward_dir = -global_transform.basis.z
	var angle = rad_to_deg(forward_dir.angle_to(direction_to_player))
	
	if angle > view_angle_degrees:
		return false
		
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 1.5, 0),
		player.global_position + Vector3(0, 1.0, 0),
		1
	)
	query.exclude = [self.get_rid()]
	var result = space_state.intersect_ray(query)
	
	return result and result.collider == player
