extends StaticBody3D

@export var nombre : String = "Llave plateada"
@export var imagen : Texture2D = preload("res://Assets/Imagenes/llavePlateada.jpeg")
func interactuar(personaje) -> bool:
	print("1. ¡Se ejecutó interactuar en la LLAVE!")
	var guardado = personaje.agregarInventario(nombre, imagen)
	print(guardado)
	if guardado:
		queue_free()
		return true
	else:
		return false
	
