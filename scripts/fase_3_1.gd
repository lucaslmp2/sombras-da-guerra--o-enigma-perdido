extends Node2D
@onready var animation_player: AnimationPlayer = $HUD/AnimationPlayer
@onready var player: CharacterBody2D = $characters/Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	animation_player.play("nigth")
	if TransitionLevel.destino_level != "":
		var point = get_node(TransitionLevel.destino_level)
		if point:
			player.global_position = point.global_position
