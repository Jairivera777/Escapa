extends StaticBody3D

@export_category("Animaciones Rápidas")
@export var abrir : String = "Abrir"
@export var cerrar : String = "cerrar"

@export_category("Animaciones Lentas")
@export var abrirlento : String = "abrirlento"
@export var cerrarLento : String = "cerrarlento"

@export_category("Niveles de Ruido (1 al 100)")
@export_range(1, 100) var ruido_abrir : int = 85
@export_range(1, 100) var ruido_abrirlento : int = 20
@export_range(1, 100) var ruido_cerrar : int = 80
@export_range(1, 100) var ruido_cerrarlento : int = 20

@export_category("Sonidos")
@export var sonido_abrir : AudioStream
@export var sonido_cerrar : AudioStream
@export var sonido_cerrar_lento : AudioStream
@export var sonido_abrir_lento : AudioStream

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

func interactuar(es_lento: bool = false) -> void:
	if animacionEnCurso:
		return
		
	animacionEnCurso = true
	var anim_objetivo : String
	var nivelRuido : int = 0
	
	if estaAbierta:
		anim_objetivo = cerrarLento if es_lento else cerrar
		sonido.stream = sonido_cerrar_lento if es_lento else sonido_cerrar
		nivelRuido = ruido_cerrarlento if es_lento else ruido_cerrar
	else:
		anim_objetivo = abrirlento if es_lento else abrir
		sonido.stream = sonido_abrir_lento if es_lento else sonido_abrir
		nivelRuido = ruido_abrirlento if es_lento else ruido_abrir
		
	sonido.unit_size = remap(nivelRuido, 1, 100, 2.0, 15.0)
		
	if sonido.stream != null:
		sonido.play()
		
	animation.play(anim_objetivo)
	emitir_alerta_ruido(nivelRuido)

func emitir_alerta_ruido(nivel : int) -> void:
	pass

func _al_terminar_animacion(anim_name : String) -> void:
	if anim_name in [abrir, abrirlento, cerrar, cerrarLento]:
		estaAbierta = !estaAbierta 
		animacionEnCurso = false
