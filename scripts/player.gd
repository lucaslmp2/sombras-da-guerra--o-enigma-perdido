extends CharacterBody2D

const SPEED = 200.0
const JUMP_FORCE = -250.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping := false
var is_attacking := false  # Adiciona flag para ataque
var player_life := 10
var knockback_vector := Vector2.ZERO

@onready var anim_soldado: AnimatedSprite2D = $anim_soldado
@onready var animation := $anim_inicial as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D

func _physics_process(delta):
	# Se está atacando, impede qualquer outro movimento
	if is_attacking:
		return  

	# Adiciona a gravidade
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
		if !is_jumping:
			animation.play("run")
	elif is_jumping:
		animation.play("jump")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animation.play("idle")

	# Verifica os inputs para ataque
	if Input.is_action_just_pressed("attack"):
		await play_attack_animation("atack_1")  # Chama a função para tocar ataque 1
	elif Input.is_action_just_pressed("attack_2"):
		await play_attack_animation("atack_2")  # Chama a função para tocar ataque 2

	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector

	move_and_slide()

	for plataforms in get_slide_collision_count():
		var collision = get_slide_collision(plataforms)
		if collision.get_collider().has_method("has_collided_with"):
			collision.get_collider().has_collided_with(collision, self)

func play_attack_animation(attack_name: String):
	is_attacking = true  # Bloqueia movimento durante o ataque
	animation.play(attack_name)
	await animation.animation_finished  # Aguarda a animação acabar
	is_attacking = false  # Libera movimento

func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path

func take_damage(knockback_force := Vector2.ZERO, duration := 0.25):
	player_life -= 1
	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		
		var knockback_tween := get_tree().create_tween()
		knockback_tween.tween_property(self, "knockback_vector", Vector2.ZERO, duration)
