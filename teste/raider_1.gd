extends CharacterBody2D
signal player_died()
@export var speed: float = 100
@export var shooting_interval: float = 2.0
@export var health: int = 3
@export var jump_force: float = -300
@export var bullet_scene: PackedScene = preload("res://Prefabs/bullet_rider_1.tscn")
@onready var tiro: AudioStreamPlayer2D = $tiro
@onready var correndo: AudioStreamPlayer2D = $correndo
@onready var morte: AudioStreamPlayer2D = $Morte
@onready var hurt: AudioStreamPlayer2D = $hurt
@export var item_scene: PackedScene = preload("res://Prefabs/drive.tscn")
@onready var player = null
@onready var raycast: RayCast2D = $RayCast2D
@onready var ray_cast_2d_2: RayCast2D = $RayCast2D2
@onready var gun: Node2D = $Gun
@onready var animation: AnimatedSprite2D = $Anim # Mudado para AnimatedSprite2D

var shooting_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_shooting := false
var should_follow_player := false
var is_dead := false # Adicionado para controlar o estado de morte
var dead_animation_finished := false

const DETECTION_RANGE_X = 500
const SHOOTING_RANGE_X = 300
const SAFE_DISTANCE_X = 100
const MAX_HEIGHT_DIFFERENCE = 50  # Tolerância de altura para evitar perseguição/tiros errados

func _ready():
	player = get_parent().get_node("character/Player")
	if is_instance_valid(player) and player.has_signal("player_died"):
		player.player_died.connect(_on_player_died)

func _physics_process(delta):
	if is_dead:
		return  # Não processa lógica se já estiver morto

	if is_instance_valid(player):
		var player_pos = player.global_position
		var distance_x = abs(player_pos.x - global_position.x)
		var distance_y = abs(player_pos.y - global_position.y)

		should_follow_player = distance_x <= DETECTION_RANGE_X and distance_y <= MAX_HEIGHT_DIFFERENCE

		if should_follow_player and not is_shooting and distance_x > SAFE_DISTANCE_X:
			var direction = (player_pos - global_position).normalized()
			velocity.x = direction.x * speed
			flip()
		else:
			velocity.x = 0

		move_and_slide()

		if should_follow_player and distance_x <= SHOOTING_RANGE_X:
			shooting_timer -= delta
			if shooting_timer <= 0 and not is_shooting:
				shoot()
				shooting_timer = shooting_interval
		else:
			is_shooting = false
	else:
		player = null
		should_follow_player = false
		is_shooting = false
		velocity.x = 0

func flip():
	if velocity.x > 0:
		animation.flip_h = false
		animation.play("run")
		raycast.position.x = abs(raycast.position.x)
	elif velocity.x < 0:
		animation.flip_h = true
		animation.play("run")
		raycast.position.x = -abs(raycast.position.x)

func shoot():
	is_shooting = true
	should_follow_player = false

	if not is_instance_valid(player):
		is_shooting = false
		return

	var angles = [-10, 0, 10]

	for i in range(3):
		var bullet = bullet_scene.instantiate()
		var offset = Vector2(30 * sign(velocity.x), 0) + Vector2(i * 10 - 10, 0)
		bullet.position = gun.global_position + offset
		var angle = deg_to_rad(angles[i])
		var direction = Vector2(cos(angle), sin(angle)).normalized()

		if is_instance_valid(player):
			var player_direction = (player.global_position - global_position).normalized()
			direction.x = player_direction.x
			bullet.velocity = direction * 600
			get_parent().add_child(bullet)
		else:
			bullet.queue_free()

	animation.play("shot")
	tiro.play()
	await get_tree().create_timer(0.3).timeout

	# **ADICIONE ESTA VERIFICAÇÃO APÓS O TIMER**
	if not is_instance_valid(player):
		is_shooting = false
		return

	await animation.animation_finished

	is_shooting = false
	should_follow_player = abs(player.global_position.x - global_position.x) <= DETECTION_RANGE_X

func take_damage(amount: int):
	if is_dead:  # Não processa dano se já estiver morto
		return
	health -= amount
	if health <= 0:
		die()
	else:
		animation.stop()
		animation.play("hurt")
		if is_instance_valid(hurt):
			hurt.play()
		await get_tree().create_timer(0.5).timeout

func die():
	if is_dead:
		return
	var chave = preload("res://Prefabs/drive.tscn").instantiate()
	chave.position = position
	get_tree().current_scene.add_child(chave)  # Adiciona à fase atual

	# Conecta o sinal do Drive ao método da fase
	if get_tree().current_scene.has_method("_on_pendrive_coletado"):
		chave.connect("pick_up_chave", get_tree().current_scene._on_pendrive_coletado)
	is_dead = true # Garante que a função die() seja chamada apenas uma vez
	animation.stop()
	animation.play("dead")
	if is_instance_valid(morte):
		morte.play()
	Globals.score += 300
	await animation.animation_finished
	queue_free()

func _on_player_died():
	player = null
	should_follow_player = false
	is_shooting = false
	velocity.x = 0
	emit_signal("player_died")
	# Você pode adicionar aqui qualquer outra lógica que este inimigo deva fazer ao player morrer
