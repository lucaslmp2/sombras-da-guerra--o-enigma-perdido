extends Area2D

@export var next_level : = ""
@onready var animation_player: AnimationPlayer = $"../HUD/AnimationPlayer"

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		animation_player.play("fade_out")
		TransitionLevel.destino_level = get_parent().name
		get_tree().call_deferred("change_scene_to_file", next_level)
