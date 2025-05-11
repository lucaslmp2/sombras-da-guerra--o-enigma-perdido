extends Area2D

@onready var novo_personagem_area: Area2D = get_node("../Novo_personagem")
@export var player_fase_2_cena: PackedScene
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $"../../HUD/AnimationPlayer"

func _ready() -> void:
	pass

func apagar_camera_do_player():
	var player_node = get_node_or_null("../../characters/Player") # Caminho ajustado
	if player_node:
		var camera_node = player_node.get_node_or_null("Camera2D2")
		if camera_node:
			camera_node.queue_free()
			print("Câmera Camera2D2 apagada do Player.")
		else:
			print("A câmera Camera2D2 não foi encontrada como filha do Player.")
	else:
		print("O nó Player não foi encontrado na cena.")

func _on_Mudanca_de_peronagem_body_entered(body: Node) -> void:
	animation_player.play("fade_out")
	await get_tree().create_timer(0.5).timeout
	animation_player.play("fade_in")
	if body.has_method("queue_free"):
		apagar_camera_do_player()
		_carregar_novo_personagem()
		await get_tree().create_timer(0.2).timeout
		body.queue_free()
		collision_shape_2d.disabled = true

func _carregar_novo_personagem() -> void:
	if player_fase_2_cena:
		var novo_player = player_fase_2_cena.instantiate()
		if novo_personagem_area:
			novo_player.global_position = novo_personagem_area.global_position
			call_deferred("adicionar_novo_player", novo_player)
		else:
			printerr("Erro: Área Novo_personagem não encontrada.")
	else:
		printerr("Erro: Cena do player da Fase 2 não foi definida no Inspetor.")

func adicionar_novo_player(novo_player: Node2D) -> void:
	get_parent().get_parent().add_child(novo_player) # Sobe dois níveis e adiciona o novo player
	print("Novo player adicionado na posição:", novo_player.global_position)
