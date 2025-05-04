extends Area2D
@onready var coletado: AudioStreamPlayer2D = $coletado

var pedra := 1
func _on_body_entered(body: Node2D) -> void:
		coletado.play()
		await get_tree().create_timer(0.3).timeout
		if body.has_method("enable_throwing") and body is CharacterBody2D:
			await $CollisionShape2D.call_deferred("queue_free")
			Globals.pedra += pedra
			if Globals.pedra > 0:
				body.enable_throwing()
			await get_tree().create_timer(0.2).timeout
			queue_free()
