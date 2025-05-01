extends CharacterBody2D

# Sinais
signal player_damaged(damage_amount)
signal player_died()
@onready var correndo: AudioStreamPlayer2D = $correndo
@onready var pulo: AudioStreamPlayer2D = $pulo
@onready var tiro: AudioStreamPlayer2D = $tiro
@onready var granada_lançada: AudioStreamPlayer2D = $granada_lançada
@onready var morte: AudioStreamPlayer2D = $morte
@onready var hurt: AudioStreamPlayer2D = $hurt

# Constantes
const SPEED = 200.0
const JUMP_FORCE = -300.0
const SHOOT_DELAY = 0.1 # Adiciona um pequeno delay para evitar disparos rápidos demais

# Recursos externos
@export var grenade_scene: PackedScene = preload("res://Prefabs/granada2.tscn")
@export var bullet_scene: PackedScene = preload("res://Prefabs/Bullet.tscn")

# Nós
@onready var marker_2d: Marker2D = $Marker2D
@onready var animation: AnimatedSprite2D = $anim_inicial

var is_running_sound_playing = false
var is_shooting = false # Nova variável para controlar se o jogador está a disparar.
var time_since_last_shot = 0.0 # Variável para controlar o tempo desde o último disparo
var has_played_death_sound = false # Variável para garantir que o som de morte toque apenas uma vez
var has_played_hurt_sound = false # Variável para garantir que o som de dano toque apenas uma vez

# Variáveis de estado
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping = false
var is_attacking = false
var knockback_vector = Vector2.ZERO
var can_throw_grenade = true

# Tirolesa
var is_on_zipline = false
var zipline_path: Path2D = null
var path_follow_node: PathFollow2D = null
var zipline_speed = 0.0
var max_zipline_speed = 150.0
var zipline_acceleration = 30.0
var zipline_release_distance = 50.0

func _ready():
	pass

func _physics_process(delta):
	time_since_last_shot += delta # Atualiza o tempo desde o último disparo

	if is_attacking:
		return

	if is_on_zipline:
		_process_zipline(delta)
		return
	

	_process_movement_topdown(delta)
	_process_movement(delta)

	if Input.is_action_just_pressed("attack") and Globals.granada > 0:
		granada_lançada.play()
		await _play_attack_animation("granade")
		_throw_grenade()
	elif Input.is_action_pressed("attack_2"): # Modificado para "is_action_pressed"
		_attack_shot()
	elif Input.is_action_just_released("attack_2"): # Adicionado para parar o som
		is_shooting = false
		tiro.stop()
		time_since_last_shot = 0.0 # Reseta o timer quando o botão é solto

	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().has_method("has_collided_with"):
			collision.get_collider().has_collided_with(collision, self)

func _process_movement_topdown(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	velocity = direction.normalized() * SPEED

	if direction != Vector2.ZERO:
		animation.play("run_gangster")

		if direction.x != 0:
			animation.scale.x = direction.x # Ajusta a direção do sprite (esquerda/direita)
	else:
		animation.play("idle_gangster")

func _process_movement(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		is_jumping = true
		animation.play("jump_gangster")
		pulo.play()
		if is_running_sound_playing:
			correndo.stop()
			is_running_sound_playing = false
	elif is_on_floor():
		is_jumping = false

	# Movimento horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction

		if is_on_floor(): # Só anima correr se estiver no chão
			animation.play("run_gangster")
			if not is_running_sound_playing:
				correndo.play()
				is_running_sound_playing = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		# Se estiver parado e no chão, toca idle
		if is_on_floor() and not is_jumping:
			animation.play("idle_gangster")
			if is_running_sound_playing:
				correndo.stop()
				is_running_sound_playing = false


func _throw_grenade():
	if can_throw_grenade and Globals.granada > 0:
		var grenade = grenade_scene.instantiate()
		grenade.position = global_position
		get_parent().add_child(grenade)

		var throw_dir = Vector2(1, -1) if animation.scale.x > 0 else Vector2(-1, -1)
		grenade.throw_grenade(throw_dir)

		Globals.granada -= 1
		if Globals.granada <= 0:
			can_throw_grenade = false

func disable_throwing():
	can_throw_grenade = false

func enable_throwing():
	can_throw_grenade = true

func _process_zipline(delta):
	if zipline_path and zipline_path.has_node("PathFollow2D"):
		path_follow_node = zipline_path.get_node("PathFollow2D")

	var input_dir = Input.get_axis("ui_left", "ui_right")
	zipline_speed += input_dir * zipline_acceleration * delta
	zipline_speed = clamp(zipline_speed, -max_zipline_speed, max_zipline_speed)

	path_follow_node.progress += zipline_speed * delta
	global_position = path_follow_node.global_position

	if path_follow_node.progress > zipline_path.curve.get_baked_length() - zipline_release_distance and zipline_speed > 0:
		_release_zipline()
	elif path_follow_node.progress < zipline_release_distance and zipline_speed < 0:
		_release_zipline()

	if Input.is_action_just_pressed("ui_accept"):
		_release_zipline()

func grab_zipline(zipline):
	if not is_on_zipline:
		is_on_zipline = true
		zipline_path = zipline
		zipline_speed = 100.0
		gravity = 0

		if zipline_path and zipline_path.has_node("PathFollow2D"):
			path_follow_node = zipline_path.get_node("PathFollow2D")
			var offset = zipline_path.curve.get_closest_offset(global_position)
			offset = clamp(offset, 0.0, zipline_path.curve.get_baked_length())
			path_follow_node.progress = offset
			global_position = path_follow_node.global_position

		velocity = Vector2.ZERO
		is_jumping = false
		animation.play("emtirolesa")

func _release_zipline():
	if is_on_zipline:
		is_on_zipline = false

		if zipline_path and zipline_path.has_node("PathFollow2D"):
			zipline_path.get_node("PathFollow2D").progress = 0.0

		zipline_path = null
		path_follow_node = null
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

		var impulse = Vector2(cos(rotation), sin(rotation)) * zipline_speed * 0.5
		velocity = impulse

func _play_attack_animation(name: String):
	is_attacking = true
	animation.play(name)
	await animation.animation_finished
	is_attacking = false

func take_damage(amount := 1, knockback := Vector2.ZERO, duration := 0.25):
	Globals.life -= amount # Use Globals.life diretamente
	# A linha Globals.life = player_life; não é mais necessária e pode ser removida.
	_play_attack_animation("hurt_gangster")
	if not has_played_hurt_sound:
		hurt.play()
		has_played_hurt_sound = true
	emit_signal("player_damaged", amount)

	if Globals.life <= 0: # Use Globals.life para verificar se o jogador morreu
		_play_attack_animation("dead_gangster")
		if not has_played_death_sound:
			morte.play()
			has_played_death_sound = true
		emit_signal("player_died")

		if has_node("CollisionShape2D"):
			call_deferred("set", "get_node(\"CollisionShape2D\").disabled", true)
		elif has_node("CollisionPolygon2D"):
			call_deferred("set", "get_node(\"CollisionPolygon2D\").disabled", true)

	if knockback != Vector2.ZERO:
		knockback_vector = knockback
		var tween = get_tree().create_tween()
		tween.tween_property(self, "knockback_vector", Vector2.ZERO, duration)

func _attack_shot():
	if Globals.bulets > 0 and time_since_last_shot >= SHOOT_DELAY: # Verifica o delay
		_shoot()
		_play_attack_animation("shot")
		is_shooting = true
		tiro.play()
		time_since_last_shot = 0.0 # Reseta o timer após o disparo
		
func _shoot():
	var bullet = bullet_scene.instantiate()
	Globals.bulets -= 1
	bullet.position = global_position + Vector2(animation.scale.x * 20, -12)
	bullet.velocity = Vector2(animation.scale.x, 0).normalized() * 600

	get_parent().add_child(bullet)
