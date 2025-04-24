extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var entrada_escritorio: Area2D = $"."  # Referência a este Area2D
@onready var colisao_entrada_escritorio: CollisionShape2D = $colisao_entrada_escritorio # Corrigido nome
@onready var saida_escritorio: CollisionShape2D = $saida_escritorio
@onready var posicao_entrega: Marker2D = $PosicaoEntrega

signal player_entrou_area  # Sinal para quando o jogador entra
signal player_saiu_area    # Sinal para quando o jogador sai

func _ready():
	# Conecta os sinais da própria área (Area2D) usando Callable
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node2D):
	# Verifica se o corpo que entrou é o jogador (você pode usar grupos)
	if body.is_in_group("player"):
		emit_signal("player_entrou_area")  # Emite o sinal
		print("Jogador entrou na área de entrada do escritório")

func _on_body_exited(body: Node2D):
	# Verifica se o corpo que saiu é o jogador
	if body.is_in_group("player"):
		emit_signal("player_saiu_area")  # Emite o sinal
		print("Jogador saiu da área de entrada do escritório")

func get_posicao_entrega() -> Marker2D:
	return posicao_entrega
