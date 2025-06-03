extends Area2D

@export var next_level : = ""
@onready var animation_player: AnimationPlayer = $"../HUD/AnimationPlayer"
@onready var saida: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	saida.disabled = true


func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		animation_player.play("fade_out")
		TransitionLevel.destino_level = get_parent().name
		get_tree().call_deferred("change_scene_to_file", next_level)

var sinais_coletados: int = 0
const total_sinais_necessarios: int = 4

func conectar_sinal_item(item_node):
	"""
	Conecta o sinal de um item instanciado à função de tratamento.

	Args:
		item_node: O nó do item instanciado que emite um dos sinais.
	"""
	if item_node.has_signal("pista_1"):
		item_node.connect("pista_1", self, "_on_pista_lida")
	elif item_node.has_signal("pista_2"):
		item_node.connect("pista_2", self, "_on_pista_lida")
	elif item_node.has_signal("pista_3"):
		item_node.connect("pista_3", self, "_on_pista_lida")
	elif item_node.has_signal("pista_4"):
		item_node.connect("pista_4", self, "_on_pista_lida")
	else:
		printerr("Item instanciado não possui um dos sinais esperados para disfarce.")

func _on_pista_lida() -> void:
	sinais_coletados += 1
	print(str(sinais_coletados) + " pistas coletadas.")
	if sinais_coletados == total_sinais_necessarios:
		_liberar_saida()

func _liberar_saida() -> void:
	if is_instance_valid(saida):
		saida.disabled = false
		print("Todos os disfarces coletados. Saída liberada.")
	else:
		print("Erro: Nó 'saida' não encontrado.")
