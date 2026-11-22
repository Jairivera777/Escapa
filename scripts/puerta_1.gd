extends StaticBody3D
@export_category("Bloqueo y llaves")
@export var estaBloqueada : bool = false
@export var idLlave : String = "llave"
@export var consumirLlave : bool = true

@export_category("Animaciones Rápidas")
@export var abrir : String = "Abrir"
@export var cerrar : String = "cerrar"

@export_category("Animaciones Lentas")
@export var abrirlento : String = "abrirlento"
@export var cerrarLento : String = "cerrarlento"

@export_category("Anmaciones de Bloqueo")
@export var cerrada : String = "bloqueada"
@export var abierta : String = "desbloquear"

@export_category("Niveles de Ruido (1 al 100)")
@export_range(1, 100) var ruido_abrir : int = 85
@export_range(1, 100) var ruido_abrirlento : int = 20
@export_range(1, 100) var ruido_cerrar : int = 80
@export_range(1, 100) var ruido_cerrarlento : int = 20
@export_range(1, 100) var ruido0 : int = 0
@export_category("Sonidos")
@export var sonido_abrir : AudioStream
@export var sonido_cerrar : AudioStream
@export var sonido_cerrar_lento : AudioStream
@export var sonido_abrir_lento : AudioStream
@export var sonido_bloqueada : AudioStream
@export var sonido_desbloquear : AudioStream

@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var sonido = $AudioStreamPlayer3D

var estaAbierta : bool = false
var animacionEnCurso : bool = false

func _ready() -> void:
	_desactivar_loop(abrir)
	_desactivar_loop(abrirlento)
	_desactivar_loop(cerrar)
	_desactivar_loop(cerrarLento)
	
	animation.animation_finished.connect(_al_terminar_animacion)

func _desactivar_loop(anim_name: String) -> void:
	if animation.has_animation(anim_name):
		animation.get_animation(anim_name).loop_mode = Animation.LOOP_NONE

func interactuar(es_lento: bool = false, item = null, jugador = null) -> void:
	if animacionEnCurso:
		return
	if estaBloqueada:
		if tieneLlaveCorrecta(item):
			print("¡ÉXITO! Llave correcta. Ejecutando animación: ", abierta)
			ejecutarAccion(abierta, sonido_desbloquear, ruido0)
			estaBloqueada = false
			if consumirLlave and jugador != null:
				jugador.consumirItem()
		else:
			print("FALLO: No tiene la llave o el nombre no coincide. Ejecutando: ", cerrada)
			ejecutarAccion(cerrada, sonido_bloqueada, ruido0)
			if jugador != null:
				jugador.mostrarAviso("Necesitas: " + idLlave)
		return
	animacionEnCurso = true
	var anim_objetivo : String
	var nivelRuido : int = 0
	var stream_objetivo : AudioStream
	
	if estaAbierta:
		anim_objetivo = cerrarLento if es_lento else cerrar
		stream_objetivo = sonido_cerrar_lento if es_lento else sonido_cerrar
		nivelRuido = ruido_cerrarlento if es_lento else ruido_cerrar
	else:
		anim_objetivo = abrirlento if es_lento else abrir
		stream_objetivo = sonido_abrir_lento if es_lento else sonido_abrir
		nivelRuido = ruido_abrirlento if es_lento else ruido_abrir
		
	ejecutarAccion(anim_objetivo, stream_objetivo, nivelRuido)
func ejecutarAccion(animacion: String, audio: AudioStream, ruido: int) -> void:
	sonido.stream = audio
	sonido.unit_size = remap(ruido, 1, 100, 2.0, 15.0)
	if sonido.stream != null:
		
		sonido.play()
	if animation.has_animation(animacion):
		animation.play(animacion)
		animacionEnCurso = true
	else:
		animacionEnCurso = false
	emitir_alerta_ruido(ruido)
func emitir_alerta_ruido(nivel : int) -> void:
	pass

func _al_terminar_animacion(anim_name : String) -> void:
	if anim_name in [abrir, abrirlento, cerrar, cerrarLento]:
		estaAbierta = !estaAbierta 
	animacionEnCurso = false
func tieneLlaveCorrecta(item) -> bool:
	if item == null:
		return false
	return item["nombre"] == idLlave
	
	
