extends Area2D

@onready var animation_player: AnimationPlayer = $"../HUD/AnimationPlayer"



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		animation_player.play("RESET") # Replace with function body.


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		animation_player.play("night")
