extends StaticBody3D

func recogerLinterna(player: Node3D) -> void:
	player.obtenerLinterna()
	queue_free()
