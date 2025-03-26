extends Node2D

@onready var elias: CharacterBody2D = $Elias
@onready var computador: Area2D = $Computador
@onready var dialogo: RichTextLabel = $Dialogo
@onready var enigma: Area2D = $Enigma
@onready var enigma_ui: Control = $Enigma/EnigmaUI
@onready var entrada_texto: LineEdit = $Enigma/EnigmaUI/EntradaTexto
@onready var button: Button = $Enigma/EnigmaUI/Button
@onready var transicao: Area2D = $Computador/Transição  # Transição
@onready var collision_transicao: CollisionShape2D = $Computador/Transição/CollisionShape2D  # Colisão da transição
@onready var historia: RichTextLabel = $Historia  # RichTextLabel para a história inicial
@onready var timer_historia: Timer = $Timer # Timer para controlar o tempo de exibição da história
@onready var trava_body: Area2D = $TravaBody  # Area2D para travar o movimento do player
@onready var collision_trava: CollisionShape2D = $TravaBody/collision # Colisão para travar o movimento do player
@export var menu_scene: String = "res://Level/main_menu.tscn"  # Define a cena do menu principal

var enigma_resolvido = false
var resposta_correta = "1942"  # Exemplo de resposta correta
var historia_concluida = false
var pode_mover = true  # Variável para controlar se o jogador pode se mover ou não
var velocidade = -200  # Velocidade do personagem
var historia_texto: String = "A Segunda Guerra Mundial está em pleno andamento. Você se encontra em uma base secreta, onde segredos valiosos estão escondidos. No entanto, a missão é mais difícil do que parece. 
Sua tarefa é decifrar enigmas e descobrir informações cruciais para alterar o curso da guerra. A jornada será perigosa e cheia de desafios. 
Use as setas do teclado para se mover e interagir com os elementos ao seu redor. As respostas corretas são a chave para avançar. 
Mas cuidado, o tempo está contra você. A cada passo que você dá, a pressão aumenta, e os enigmas ficam mais difíceis. Apenas aqueles que desvendarem os mistérios conseguirão completar a missão... 
Vamos começar. Prepare-se, a missão está prestes a começar!"
var indice_texto: int = 0  # Índice do texto que será exibido
var velocidade_digitar: float = 0.07  # Velocidade do efeito de digitação (em segundos por letra)

func _ready():
	# Inicializa a história com uma string vazia para que o efeito de digitação funcione
	historia.text = ""
	
	# Desativa o movimento do personagem
	pode_mover = true
	
	# Inicia o timer para controlar a exibição do texto gradualmente
	timer_historia.start(velocidade_digitar)  # Começa a digitar o texto com a velocidade definida
	timer_historia.timeout.connect(_on_timer_timeout)  # Conecta o evento de timeout do timer
	
	# Conecta o botão
	if not button.pressed.is_connected(_on_button_pressed):
		button.pressed.connect(_on_button_pressed)
	
	# Configurações iniciais
	enigma_ui.visible = false
	transicao.visible = false  # Garante que a transição comece oculta
	collision_transicao.disabled = true  # Desativa a colisão da transição inicialmente
	computador.body_entered.connect(_on_computador_colidido)
	computador.body_exited.connect(_on_computador_saida)  
	enigma.body_entered.connect(_on_enigma_interacao)
	entrada_texto.text_submitted.connect(_on_resposta_digitada)

	# Desativa a colisão para o personagem ficar travado
	collision_trava.disabled = true

func _on_timer_timeout():
	# Exibe a próxima letra do texto a cada "timeout" do timer
	if indice_texto < historia_texto.length():
		historia.text += historia_texto[indice_texto]  # Adiciona uma letra ao texto
		indice_texto += 1  # Incrementa o índice
	else:
		timer_historia.stop()  # Para o timer quando o texto foi totalmente exibido
		_on_historia_concluida()  # Chama a função para concluir a história

func _on_historia_concluida():
	# Ao terminar a história, libera o movimento do personagem
	historia_concluida = true
	pode_mover = false  # Permite que o personagem se movimente agora
	historia.visible = false  # Oculta o texto da história

	# Ativa a colisão do TravaBody para permitir que o personagem se mova
	collision_trava.disabled = false  # Habilita a colisão para que o personagem possa se mover

# Funções de interação com o computador e enigma
func _on_computador_colidido(body):
	if body == elias and not enigma_resolvido:
		dialogo.text = "Qual o ano da batalha de Stalingrado?"

func _on_computador_saida(body):
	if body == elias:
		dialogo.text = ""  # Oculta o diálogo ao sair da área

func _on_enigma_interacao(body):
	if body == elias and not enigma_resolvido:
		enigma_ui.visible = true
		entrada_texto.grab_focus()

func _on_resposta_digitada(texto):
	if texto == resposta_correta:
		enigma_resolvido = true
		dialogo.text = "Você decifrou o enigma!"
		enigma_ui.visible = false
		transicao.visible = true  # Faz a transição aparecer
		collision_transicao.disabled = false  # Ativa a colisão da transição ao resolver o enigma
	else:
		dialogo.text = "Resposta incorreta. Tente novamente."
		entrada_texto.text = ""

func _on_button_pressed():
	_on_resposta_digitada(entrada_texto.text)  # Usa o texto digitado para validar
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)  # Volta para o menu principal
# Lógica de movimento
func _process(delta):
		
	if pode_mover:
		var movimento = Vector2.ZERO
		
		# Movimentação horizontal
		if Input.is_action_pressed("ui_right"):
			movimento.x = velocidade
		elif Input.is_action_pressed("ui_left"):
			movimento.x = -velocidade

		# Aplica o movimento com move_and_slide
		# Para garantir que o movimento só aconteça no eixo X (não afete a gravidade)
		elias.velocity.x = movimento.x  # Definir apenas o eixo X, a gravidade vai ser aplicada automaticamente
		elias.move_and_slide()  # Move o personagem sem interferir na gravidade
	else:
		# Impede movimento no eixo X e a gravidade continuará sendo aplicada
		elias.velocity.x = 0  # Impede qualquer movimento no eixo X
		elias.move_and_slide()  # A gravidade será aplicada normalmente, mas sem movimento horizontal
