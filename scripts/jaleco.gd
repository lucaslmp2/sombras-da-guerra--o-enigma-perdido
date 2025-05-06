extends Area2D
@onready var pick_up: AudioStreamPlayer2D = $pick_up

signal capuz_coletado

func _on_body_entered(body: Node2D) -> void:
	pick_up.play()
	await pick_up.finished
	emit_signal("capuz_coletado")
	if body.is_in_group("player"):
		queue_free()
