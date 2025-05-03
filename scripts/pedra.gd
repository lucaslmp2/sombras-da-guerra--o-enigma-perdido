extends Area2D
@onready var coletado: AudioStreamPlayer2D = $coletado

var pedra := 1
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		coletado.play()
		await $CollisionShape2D.call_deferred("queue_free")
		await get_tree().create_timer(0.3).timeout
		Globals.pedra += pedra
		queue_free()
	else:
		print("Corpo que entrou não é o player ou não tem 'enable_throwing'")
