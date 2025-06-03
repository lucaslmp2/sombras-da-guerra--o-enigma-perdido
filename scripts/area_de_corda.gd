extends Area2D
@onready var sprite_2d: Sprite2D = $CollisionPolygon2D/Sprite2D
@onready var animated_sprite_2d: AnimatedSprite2D = $CollisionPolygon2D/AnimatedSprite2D
@onready var correntes: Sprite2D = $CollisionPolygon2D/Correntes
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_body_entered(body):
	if body.has_method("grab_zipline"):
		animated_sprite_2d.play("engrenagens")
		audio_stream_player_2d.play()
		correntes.visible = false
		sprite_2d.visible = false
		body.grab_zipline(get_parent().get_parent()) # Passa o nó Path2D ("Corda")
		
