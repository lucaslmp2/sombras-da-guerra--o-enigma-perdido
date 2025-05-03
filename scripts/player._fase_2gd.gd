extends CharacterBody2D

# Sinais
signal player_damaged(damage_amount)
signal player_died()

@onready var correndo: AudioStreamPlayer2D = $correndo
@onready var pulo: AudioStreamPlayer2D = $pulo
@onready var tiro: AudioStreamPlayer2D = $tiro
@onready var granada_lançada: AudioStreamPlayer2D = $granada_lançada
@onready var morte: AudioStreamPlayer2D = $morte
@onready var hurt_sound: AudioStreamPlayer2D = $hurt # Renomeei para evitar confusão com a animação
var is_undercover = true # Ativa o conjunto de animações alternativas

# Constantes
const SPEED = 200.0
const JUMP_FORCE = -300.0
const KNOCKBACK_FADE_DURATION = 0.25

# Nós
@onready var marker_2d: Marker2D = $Marker2D
@onready var animation: AnimatedSprite2D = $anim_inicial

var is_running_sound_playing = false
var has_played_death_sound = false
var has_played_hurt_sound = false

# Variáveis de estado
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping = false
var is_attacking = false
var knockback_vector = Vector2.ZERO

# Tirolesa
var is_on_zipline = false
var zipline_path: Path2D = null
var path_follow_node: PathFollow2D = null
var zipline_speed = 0.0
var max_zipline_speed = 150.0
var zipline_acceleration = 30.0
var zipline_release_distance = 50.0

func play_animation(name: String):
	var anim_name = name
	if is_undercover:
		match name:
			"idle":
				anim_name = "idle"
			"run":
				anim_name = "run"
			"walk":
				anim_name = "walk"
			"jump":
				anim_name = "jump"
			"hurt":
				anim_name = "hurt"
			"dead":
				anim_name = "dead"
			"atack_1", "atack_2", "atack_3":
				anim_name = name
			_:
				printerr("Animação desconhecida: ", name)
				return
	else:
		match name:
			"idle":
				anim_name = "idle_gangster"
			"run":
				anim_name = "run_gangster"
			"walk":
				anim_name = "walk_gangster"
			"jump":
				anim_name = "jump_gangster"
			"hurt":
				anim_name = "hurt_gangster"
			"dead":
				anim_name = "dead_gangster"
			"atack_1", "atack_2", "atack_3":
				anim_name = name + "_gangster"
			_:
				printerr("Animação desconhecida (gangster): ", name)
				return

	animation.play(anim_name)

func _ready():
	is_undercover = true # quando a fase "Berlim 1943" começar
	play_animation("idle") # Inicia com a animação de idle

func _physics_process(delta):
	if is_attacking:
		return

	if is_on_zipline:
		_process_zipline(delta)
		return

	_process_movement(delta)
	_process_jump()
	_process_attack_input()

	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
	else:
		velocity.y += gravity * delta

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().has_method("has_collided_with"):
			collision.get_collider().has_collided_with(collision, self)

func _process_movement(delta):
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction
		if not is_jumping and not is_on_zipline:
			play_animation("run")
			if not is_running_sound_playing:
				correndo.play()
				is_running_sound_playing = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_jumping and not is_on_zipline:
			play_animation("idle")
		if is_running_sound_playing:
			correndo.stop()
			is_running_sound_playing = false

func _process_jump():
	if is_on_floor():
		is_jumping = false
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_FORCE
			is_jumping = true
			play_animation("jump")
			pulo.play()
	elif velocity.y < 0 and not is_on_zipline:
		if not animation.is_playing() or not animation.get_animation().begins_with("jump"):
			play_animation("jump") # Mantém a animação de pulo no ar
	elif velocity.y > 0 and not is_on_zipline and not is_attacking:
		if not animation.is_playing() or not animation.get_animation().begins_with("jump"):
			play_animation("idle") # Transiciona para idle ao cair (pode ajustar para outra animação)

func _process_attack_input():
	if Input.is_action_just_pressed("attack_1"):
		_play_attack_animation("atack_1")
	elif Input.is_action_just_pressed("attack_2"):
		_play_attack_animation("atack_2")
	elif Input.is_action_just_pressed("attack_3"):
		_play_attack_animation("atack_3")

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
		play_animation("walk") # Ou outra animação apropriada para tirolesa

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
	play_animation(name)
	await animation.animation_finished
	is_attacking = false

func take_damage(amount := 1, knockback := Vector2.ZERO, duration := KNOCKBACK_FADE_DURATION):
	Globals.life -= amount
	play_animation("hurt")
	if not has_played_hurt_sound:
		hurt_sound.play()
		has_played_hurt_sound = true
	emit_signal("player_damaged", amount)

	if Globals.life <= 0:
		play_animation("dead")
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

func _on_animation_finished():
	if animation.get_current_animation() == "hurt" or animation.get_current_animation() == "dead":
		has_played_hurt_sound = false # Permite tocar o som de dano novamente
		has_played_death_sound = false # Permite tocar o som de morte novamente
