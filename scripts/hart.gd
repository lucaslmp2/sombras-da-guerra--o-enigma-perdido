extends Area2D
@onready var anim: AnimatedSprite2D = $Anim

var hart := 1
func _on_body_entered(body: Node2D) -> void:
	anim.play("collect")
	Globals.life += hart
	await anim.animation_finished
	queue_free()
