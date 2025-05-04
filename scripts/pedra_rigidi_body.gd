extends RigidBody2D

@onready var rolando_no_chão: AudioStreamPlayer2D = $rolando_no_chão
@onready var detector: Area2D = $Detector
@export var damage := 1

func _ready():
	rolando_no_chão.play()

func _physics_process(delta):
	if linear_velocity.length() > 10 and !rolando_no_chão.playing:
		rolando_no_chão.play()
	elif linear_velocity.length() <= 10:
		rolando_no_chão.stop()

func throw_stone(direction: Vector2):
	var speed = 600
	var upward_boost = -200
	linear_velocity = (direction.normalized() * speed) + Vector2(0, upward_boost)

func _on_detector_body_detected(body):
	print("Detector bateu em:", body)
	if body.has_method("take_damage"):
		print("Causando dano ao inimigo")
		body.take_damage(damage)
	queue_free()


func _on_detector_area_entered(area: Area2D) -> void:
	queue_free()
