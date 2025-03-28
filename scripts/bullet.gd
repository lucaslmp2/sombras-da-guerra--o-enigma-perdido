extends Area2D

@export var speed : float = 400

var velocity : Vector2

func _physics_process(delta):
	position += velocity * delta

func set_velocity(direction : Vector2):
	velocity = direction * speed

func _on_area_entered(area):
	if area.has_method("take_damage"):
		area.take_damage(1)
	queue_free()

func _on_area_exited(area):
	queue_free()
