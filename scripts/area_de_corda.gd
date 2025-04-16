extends Area2D
@onready var sprite_2d: Sprite2D = $CollisionPolygon2D/Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $CollisionPolygon2D/AnimatedSprite2D

func _on_body_entered(body):
	print("AREA DA CORDA: Um corpo entrou na área:", body.name)
	if body.has_method("agarrar_tirolesa"):
		animated_sprite_2d.play("engrenagens")
		print("AREA DA CORDA: O corpo", body.name, "tem o método 'agarrar_tirolesa'.")
		body.agarrar_tirolesa(get_parent().get_parent()) # Passa o nó Path2D ("Corda")
		print("AREA DA CORDA: Chamou a função 'agarrar_tirolesa' no corpo:", body.name, "com a corda:", get_parent().get_parent().name)
	else:
		print("AREA DA CORDA: O corpo", body.name, "NÃO tem o método 'agarrar_tirolesa'.")
