extends Node2D
@onready var animation_player: AnimationPlayer = $HUD/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	animation_player.play("nigth")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
