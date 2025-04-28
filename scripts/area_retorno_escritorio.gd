extends Area2D

@export var destino_escritorio: NodePath
@onready var fade_layer: CanvasLayer = $"/root/Fase_1/FadeLayer"
@onready var fade_anim = $"/root/Fase_1/FadeLayer/FadeAnim"
@onready var camera_jogador: Camera2D = $"../../Characteres/Elias/Camera_jogador"
@onready var porta: AudioStreamPlayer2D = $"../Porta"



func _on_body_entered(body):
	if body.name == "Elias":
		porta.play()
		fade_layer.visible = true
		fade_anim.play("fade_out")
		await fade_anim.animation_finished

		# Move o jogador
		body.global_position = get_node(destino_escritorio).global_position

		# Volta a câmera do jogador como ativa
		camera_jogador.make_current()

		# Fade in para voltar à cena
		fade_anim.play("fade_in")
		await fade_anim.animation_finished

		fade_layer.visible = false
