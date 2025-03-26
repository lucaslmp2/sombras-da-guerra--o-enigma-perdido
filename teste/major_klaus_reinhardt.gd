extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $Anim

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var velocidade = 200  # Velocidade do jogador
var velocidade_salto = 600  # Velocidade do salto
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping := false
var player_life := 10
var knockback_vector := Vector2.ZERO
# Variáveis de controle
var movimento = Vector2.ZERO
const JUMP_FORCE = -250.0

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
		animation.play("idle")
		
		
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
		
	move_and_slide()
