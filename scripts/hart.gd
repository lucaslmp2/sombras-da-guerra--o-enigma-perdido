extends Area2D
@onready var anim: AnimatedSprite2D = $Anim

var hart := 1
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body is CharacterBody2D: # Supondo que o player tem 'take_damage'
		anim.play("collect")
		await $collision.call_deferred("queue_free")
		Globals.life += hart
		await anim.animation_finished
		queue_free()
	else:
		print("Corpo que entrou não é o player.")
