extends Area2D
@onready var anim: AnimatedSprite2D = $Anim
@onready var pickup: AudioStreamPlayer2D = $pickup

var hart := 1
func _on_body_entered(body: Node2D) -> void:
	pickup.play()
	if body.has_method("enable_throwing") and body is CharacterBody2D:
		anim.play("collect")
		Globals.life += hart
		await anim.animation_finished
		queue_free()
	else:
		print("Corpo que entrou não é o player ou não tem 'enable_throwing'")
