extends Area2D
@onready var pick_up: AudioStreamPlayer2D = $pick_up
@onready var comemoração: AudioStreamPlayer2D = $comemoração

signal camisa_coletada

func _on_body_entered(body: Node2D) -> void:
	pick_up.play()
	await pick_up.finished
	emit_signal("camisa_coletada")
	if body.is_in_group("player"):
		queue_free()
