extends Area2D

@export var speed : float = 400
@onready var ricochet: AudioStreamPlayer2D = $ricochet

var velocity : Vector2
var bullet := Globals.bulets
func _physics_process(delta):
	position += velocity * delta
func _ready() -> void:
	ricochet.play()
func set_velocity(direction : Vector2):
	velocity = direction * speed

func _on_area_entered(area):
	if area.has_method("take_damage"):
		bullet -= 1
		area.take_damage(1)
	queue_free()

func _on_area_exited(area):
	bullet -= 1
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
		bullet -= 1
	queue_free()

func _on_body_exited(body: Node2D) -> void:
	bullet -= 1
	queue_free()
