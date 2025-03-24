extends Node2D

@onready var dialogo = $Dialogo  # Referência ao RichTextLabel para exibir mensagens
@onready var interacao = $Computador  # Referência ao nó de interação (computador)
@onready var transicao = $"Transição"  # Referência ao nó de transição
@onready var enigma = $Enigma  # Referência ao enigma
@onready var player = $Elias  # Referência ao jogador

var enigma_resolvido = false  # Flag para verificar se o enigma foi resolvido
var is_near_computador = false  # Flag para verificar se o jogador está perto do computador

# Função para mostrar mensagens no RichTextLabel
func mostrar_mensagem(mensagem: String) -> void:
	dialogo.text = mensagem  # Atualiza o texto do RichTextLabel

# Função chamada quando o jogador entra na área de interação do computador
func _on_objeto_interagido(objeto: String):
	if objeto == "computador":
		mostrar_mensagem("Você está diante de um enigma: 'H.E.L.L.O'. Tente decifrar.")  # Exibe o enigma
		enigma_visivel(true)  # Torna o enigma visível

# Função chamada automaticamente quando o jogador entra na área de interação
func _on_Computador_body_entered(body: Node):
	if body.is_in_group("player"):  # Verifica se é o jogador
		is_near_computador = true  # Jogador entrou na área de interação

# Função chamada automaticamente quando o jogador sai da área de interação
func _on_Computador_body_exited(body: Node):
	if body.is_in_group("player"):  # Verifica se é o jogador
		is_near_computador = false  # Jogador saiu da área de interação

# Função para resolver o enigma
func resolver_enigma(codigo: String):
	if codigo == "H.E.L.L.O":
		enigma_resolvido = true
		mostrar_mensagem("Enigma resolvido com sucesso!")
		enigma_visivel(false)  # Oculta o enigma
		transicao.iniciar_transicao("res://Level/fase1.tscn")  # Transição para a próxima fase

# Função para mostrar ou esconder o enigma
func enigma_visivel(visivel: bool) -> void:
	$Enigma.visible = visivel  # Torna o enigma visível ou invisível

# Função para interagir com o computador (pressionando a tecla de interação)
func _process(delta):
	if is_near_computador and Input.is_action_just_pressed("ui_accept"):  # Verifica se o jogador pressionou a tecla de interação
		_on_objeto_interagido("computador")  # Chama a função de interação
