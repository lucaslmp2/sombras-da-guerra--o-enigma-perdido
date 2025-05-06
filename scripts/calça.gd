extends Area2D
@onready var pick_up: AudioStreamPlayer2D = $pick_up
signal calca_coletada

func _on_body_entered(body: Node2D) -> void:
	pick_up.play()
	await pick_up.finished
	emit_signal("calca_coletada")
	if body.is_in_group("player"):
		queue_free()
