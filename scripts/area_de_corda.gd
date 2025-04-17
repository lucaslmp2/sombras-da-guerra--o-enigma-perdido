extends Area2D
@onready var sprite_2d: Sprite2D = $CollisionPolygon2D/Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $CollisionPolygon2D/AnimatedSprite2D
@onready var correntes: Sprite2D = $CollisionPolygon2D/Correntes

func _on_body_entered(body):
	if body.has_method("agarrar_tirolesa"):
		animated_sprite_2d.play("engrenagens")
		correntes.visible = false
		sprite_2d.visible = false
		body.agarrar_tirolesa(get_parent().get_parent()) # Passa o nó Path2D ("Corda")
		
