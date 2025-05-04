extends Area2D

signal body_detected(body)

var already_collided := false

func _on_body_entered(body):
	if already_collided:
		return
	already_collided = true
	emit_signal("body_detected", body)

func reset_collision():
	already_collided = false
