extends Area2D


@onready var porta: AudioStreamPlayer2D = $porta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		porta.play()
		await get_tree().create_timer(0.2).timeout
		body.queue_free()
