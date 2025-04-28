extends CharacterBody2D

# Sinais
signal player_damaged(damage_amount)
signal player_died()
@onready var correndo: AudioStreamPlayer2D = $correndo
@onready var pulo: AudioStreamPlayer2D = $pulo

# Constantes
const SPEED = 200.0
const JUMP_FORCE = -300.0

# Recursos externos
@export var grenade_scene: PackedScene = preload("res://Prefabs/granada2.tscn")
@export var bullet_scene: PackedScene = preload("res://Prefabs/Bullet.tscn")

# Nós
@onready var marker_2d: Marker2D = $Marker2D
@onready var animation: AnimatedSprite2D = $anim_inicial
@onready var remote_transform: RemoteTransform2D = $remote

var is_running_sound_playing = false
# Variáveis de estado
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping = false
var is_attacking = false
var player_life = Globals.life
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
	player_life = Globals.life

func _physics_process(delta):
	if is_attacking:
		return

	if is_on_zipline:
		_process_zipline(delta)
		return

	_process_movement(delta)

	if Input.is_action_just_pressed("attack") and Globals.granada > 0:
		await _play_attack_animation("granade")
		_throw_grenade()
	elif Input.is_action_just_pressed("attack_2"):
		_attack_shot()

	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().has_method("has_collided_with"):
			collision.get_collider().has_collided_with(collision, self)

func _process_movement(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		is_jumping = true
		animation.play("jump_gangster")
		pulo.play() # Toca o som de pulo aqui
		if is_running_sound_playing:
			correndo.stop() # Para o som se pular enquanto corre
			is_running_sound_playing = false
	elif is_on_floor():
		is_jumping = false

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction
		if is_jumping:
			pass # Mantém a animação de pulo enquanto estiver pulando e se movendo
		else:
			animation.play("run_gangster")
			if not is_running_sound_playing:
				correndo.play()
				is_running_sound_playing = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_jumping:
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

		if zipline_path.has_node("PathFollow2D"):
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

func follow_camera(camera):
	remote_transform.remote_path = camera.get_path()

func take_damage(amount := 1, knockback := Vector2.ZERO, duration := 0.25):
	player_life -= amount
	Globals.life = player_life
	_play_attack_animation("hurt_gangster")
	emit_signal("player_damaged", amount)

	if player_life <= 0:
		_play_attack_animation("dead_gangster")
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
	if Globals.bulets > 0:
		_shoot()
		_play_attack_animation("shot")

func _shoot():
	var bullet = bullet_scene.instantiate()
	Globals.bulets -= 1

	bullet.position = global_position + Vector2(animation.scale.x * 20, -12)
	bullet.velocity = Vector2(animation.scale.x, 0).normalized() * 600

	get_parent().add_child(bullet)

func can_grab_zipline():
	return true
