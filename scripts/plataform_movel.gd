extends Node2D
const WAIT_DURATION := 1.0
@onready var plataform: AnimatableBody2D = $Plataform
@export var movie_speed := 3.0
@export var distance := 192
@export var movie_horizontal := true
var follow := Vector2.ZERO
var plataform_center := 16
func _ready() -> void:
	_move_plataform()
func _physics_process(delta: float) -> void:
	plataform.position = plataform.position.lerp(follow, 0.5)
func _move_plataform():
	var move_direction = Vector2.RIGHT * distance if movie_horizontal else Vector2.UP * distance
	var duration = move_direction.length() / float(movie_speed * plataform_center)
	
	var plataform_twee = create_tween().set_loops().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	plataform_twee.tween_property(self, "follow", move_direction, duration).set_delay(WAIT_DURATION)
	plataform_twee.tween_property(self, "follow", Vector2.ZERO, duration).set_delay(duration + WAIT_DURATION * 2)
