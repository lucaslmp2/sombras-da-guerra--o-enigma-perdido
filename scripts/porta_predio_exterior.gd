extends Area2D

@export var destino: NodePath
@export var destino_exterior: NodePath
@onready var camera_entrega: Camera2D = $"../../Entrega/Camera_entrega"
@onready var camera_jogador: Camera2D = $"../../Characteres/Elias/Camera_jogador"
@export var chest: NodePath
@export var campainha_audio: NodePath
@onready var fade_anim = $"/root/Fase_1/FadeLayer/FadeAnim"
@onready var fade_layer: CanvasLayer = $"../../FadeLayer"

var evento_realizado := false  # <- flag de controle

func _on_body_entered(body):
	if body.name == "Elias" and not evento_realizado:
		evento_realizado = true  # impede que o evento repita

		body.global_position = get_node(destino).global_position
		await get_tree().create_timer(2.0).timeout
		get_node(campainha_audio).play()
		await get_tree().create_timer(0.5).timeout

		# Fade out e muda para câmera da entrega
		fade_layer.visible = true
		fade_anim.play("fade_out")
		await fade_anim.animation_finished

		camera_entrega.make_current()

		# Fade in na entrega
		fade_anim.play("fade_in")
		await fade_anim.animation_finished

		await get_tree().create_timer(1.5).timeout

		# Mostra o baú
		var chest_node = get_node(chest)
		chest_node.visible = true
		if chest_node.has_node("AnimationPlayer"):
			chest_node.get_node("AnimationPlayer").play("aparecer")

		await get_tree().create_timer(2.0).timeout

		# Volta para o jogador
		fade_anim.play("fade_out")
		await fade_anim.animation_finished
		camera_jogador.make_current()
		fade_anim.play("fade_in")
		await fade_anim.animation_finished
		fade_layer.visible = false

		# Espera antes de voltar ao exterior
		await get_tree().create_timer(1.0).timeout

		# Volta ao exterior
		fade_layer.visible = true
		fade_anim.play("fade_out")
		await fade_anim.animation_finished

		body.global_position = get_node(destino_exterior).global_position

		fade_anim.play("fade_in")
		await fade_anim.animation_finished
		fade_layer.visible = false
