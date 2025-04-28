extends Area2D

@export var destino_exterior: NodePath
@onready var fade_anim = $"/root/Fase_1/FadeLayer/FadeAnim"
@onready var fade_layer: CanvasLayer = $"../../FadeLayer"
@onready var porta: AudioStreamPlayer2D = $"../Porta"

func _on_body_entered(body: Node2D) -> void:
	# Volta ao exterior
	porta.play()
	fade_layer.visible = true
	fade_anim.play("fade_out")
	await fade_anim.animation_finished
	body.global_position = get_node(destino_exterior).global_position# Replace with function body.
	fade_anim.play("fade_in")
	await fade_anim.animation_finished
	fade_layer.visible = false
