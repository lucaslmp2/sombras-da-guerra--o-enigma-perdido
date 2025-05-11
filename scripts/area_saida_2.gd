extends Area2D
@onready var porta: AudioStreamPlayer2D = $porta
@onready var saida: CollisionShape2D = $saida2
@onready var animation_player: AnimationPlayer = $"../HUD/AnimationPlayer"

@onready var area_entrada: Area2D = get_node("../AreaEntrada2") # Referência para a Area2D chamada "Entrada"
@export var player_layer: int = 1 # A layer do CollisionObject2D do seu player
@export var teleport_offset: float = 50.0 # Distância para se mover à frente (ajuste conforme necessário)
func _on_body_entered(body: Node2D) -> void:
	animation_player.play("fade_out")
	await get_tree().create_timer(0.5).timeout
	animation_player.play("fade_in")
	porta.play()
	if body.get_collision_layer_value(player_layer):
		if area_entrada and area_entrada.has_node("entrada2"):
			var entrada_colisao = area_entrada.get_node("entrada2") as CollisionShape2D # Obtém a CollisionShape2D
			var posicao_entrada = entrada_colisao.global_position
			var direcao_entrada = Vector2.RIGHT.rotated(entrada_colisao.global_rotation) # Assume que a "frente" local é para a direita

			# Calcula a nova posição à frente
			var nova_posicao = posicao_entrada + direcao_entrada * teleport_offset

			body.global_position = nova_posicao

var sinais_coletados: int = 0
const total_sinais_necessarios: int = 5

func conectar_sinal_item(item_node):
	"""
	Conecta o sinal de um item instanciado à função de tratamento.

	Args:
		item_node: O nó do item instanciado que emite um dos sinais.
	"""
	if item_node.has_signal("chapeu_coletado"):
		item_node.connect("chapeu_coletado", self, "_on_disfarce_coletado")
	elif item_node.has_signal("camisa_coletada"):
		item_node.connect("camisa_coletada", self, "_on_disfarce_coletado")
	elif item_node.has_signal("calca_coletada"):
		item_node.connect("calca_coletada", self, "_on_disfarce_coletado")
	elif item_node.has_signal("arma_coletada"):
		item_node.connect("arma_coletada", self, "_on_disfarce_coletado")
	elif item_node.has_signal("capuz_coletado"):
		item_node.connect("capuz_coletado", self, "_on_disfarce_coletado")
	else:
		printerr("Item instanciado não possui um dos sinais esperados para disfarce.")

func _on_disfarce_coletado() -> void:
	sinais_coletados += 1
	print(str(sinais_coletados) + " disfarces coletados.")
	if sinais_coletados == total_sinais_necessarios:
		_liberar_saida()

func _liberar_saida() -> void:
	if is_instance_valid(saida):
		saida.disabled = false
		print("Todos os disfarces coletados. Saída liberada.")
	else:
		print("Erro: Nó 'saida' não encontrado.")
