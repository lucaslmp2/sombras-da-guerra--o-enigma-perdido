extends Area2D
@onready var anim: AnimatedSprite2D = $Anim

var granada := 1
func _on_body_entered(body: Node2D) -> void:
	anim.play("collect")
	await $collision.call_deferred("queue_free")
	Globals.granada += granada
	await anim.animation_finished
	queue_free()
