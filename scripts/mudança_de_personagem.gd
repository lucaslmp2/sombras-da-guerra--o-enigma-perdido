extends Area2D

@onready var novo_personagem_area: Area2D = get_node("../Novo_personagem")
@export var player_fase_2_cena: PackedScene
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $"../../HUD/AnimationPlayer"

func _ready() -> void:
	Globals.bulets = 10
	Globals.granada = 3

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
		_ready() # Isso vai resetar Globals.bulets e Globals.granada ao mudar de personagem
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
	var characters_node = get_tree().get_first_node_in_group("characters")
	if characters_node:
		characters_node.add_child(novo_player)
		print("Novo player adicionado ao nó 'characters' (via grupo) na posição:", novo_player.global_position)

		# Conecta o sinal player_died do novo player ao reload_game deste script
		if novo_player.has_signal("player_died"):
			# Importante: O sinal agora será conectado ao 'reload_game' LOCAL deste script
			novo_player.player_died.connect(Callable(self, "reload_game"))
			print("Sinal 'player_died' do novo player conectado ao 'reload_game' local.")
		else:
			printerr("Erro: O novo player não emite o sinal 'player_died'.")

	else:
		printerr("Erro: Nó 'characters' com o grupo 'characters' não encontrado.")


### **Nova função `reload_game` (neste script `Mudanca_de_peronagem.gd`):**

func reload_game():
	Globals.life = 3 # Reseta a vida
	Globals.bulets = 10
	Globals.score = 0
	animation_player.play("fade_out") # Inicia o fade out
	await animation_player.animation_finished # Espera o fade out terminar

	# Encontra o player atual (o que morreu) e o remove
	var current_player = get_tree().get_first_node_in_group("player") # Assumindo que seu player está no grupo "player"
	if current_player and is_instance_valid(current_player):
		current_player.queue_free()
		print("Player anterior removido.")

	# Reinstancia e posiciona o novo player
	_carregar_novo_personagem() # Essa função já instancia e posiciona o novo player no novo_personagem_area
	print("Novo player reiniciado na posição de início da fase 2.")

	# Inicia o fade in
	animation_player.play("fade_in")
