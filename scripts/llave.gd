extends StaticBody3D

@export var nombre : String = "Llave plateada"
@export var imagen : Texture2D = preload("res://Assets/Imagenes/llavePlateada.jpeg")
func interactuar(personaje) -> bool:
	var guardado = personaje.agregarInventario(nombre, imagen)
	if guardado:
		queue_free()
		return true
	else:
		return false
	
