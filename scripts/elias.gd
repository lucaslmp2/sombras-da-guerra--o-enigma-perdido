extends CharacterBody2D


@onready var animation := $AnimatedSprite2D as AnimatedSprite2D
var velocidade = 200  # Velocidade do jogador
var velocidade_salto = 600  # Velocidade do salto
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping := false
var player_life := 10
var knockback_vector := Vector2.ZERO
# Variáveis de controle
var movimento = Vector2.ZERO
const SPEED = 200.0
const JUMP_FORCE = -250.0
@onready var computador_area = null  # Área de interação do computador
var is_near_computador = false  # Flag para verificar se o jogador está perto do computador

# Função chamada a cada quadro de física
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	var direction = Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction
		if !is_jumping: #if is_not jumping
			animation.play("walk")
	elif is_jumping: #is_jumping == true
		animation.play("jump")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animation.play("idle2")
		
		
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
		
	move_and_slide()

	# Verifica colisão com o computador (item interativo)
	if is_near_computador and Input.is_action_just_pressed("ui_accept"):
		_on_objeto_interagido("computador")

# Detecta quando o jogador entra ou sai da área de interação do computador
func _on_Area2D_body_entered(body: Node):
	if body.is_in_group("player"):  # Verifica se o corpo que entrou é o jogador
		is_near_computador = true  # Jogador entrou na área de interação

func _on_Area2D_body_exited(body: Node):
	if body.is_in_group("player"):  # Verifica se o corpo que saiu é o jogador
		is_near_computador = false  # Jogador saiu da área de interação

# Função chamada quando o jogador interage com o computador
func _on_objeto_interagido(objeto: String):
	if objeto == "computador":
		print("Jogador interagiu com o computador")
		# Coloque aqui o código para interagir com o computador, como mostrar o enigma
