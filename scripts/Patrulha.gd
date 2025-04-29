extends CharacterBody2D

const DETECTION_RANGE_X = 500     # Distância máxima para detectar o player no eixo X
const SAFE_DISTANCE_X = 100     # Distância mínima para parar de avançar
const SHOOT_DISTANCE_X = 200     # Distância ideal para atirar
const HEIGHT_TOLERANCE = 30     # Margem de tolerância no eixo Y para considerar que estão na mesma altura
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gun: Node2D = $Gun/Marker2D
@onready var wall_ray = $WallRay
@export var direction: int = 1     # 1 para direita, -1 para esquerda
@export var speed: float = 100
@export var health: int = 5     # Vida do inimigo
@export var bullet_scene: PackedScene = preload("res://Prefabs/bullet_rider_1.tscn")
@onready var tiro: AudioStreamPlayer2D = $tiro
@onready var correndo: AudioStreamPlayer2D = $correndo
@onready var patrulhando: AudioStreamPlayer2D = $patrulhando
@onready var morte: AudioStreamPlayer2D = $morte
@onready var hurt: AudioStreamPlayer2D = $hurt

var player: Node2D = null
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_shooting := false
var should_follow_player := false
var is_dead := false # Adicionado para evitar chamadas de som após a morte
var dead_animation_finished := false

func _ready():
	player = get_parent().get_node("character/Player")
	if is_instance_valid(patrulhando):
		patrulhando.play()

func _physics_process(delta):
	if is_dead:
		return   # Não processa lógica se já estiver morto

	if not is_on_floor():
		velocity.y += gravity * delta

	var distance_x = INF
	var distance_y = INF

	# Verifica se a referência do jogador ainda é válida
	if player:
		distance_x = abs(player.global_position.x - global_position.x)
		distance_y = abs(player.global_position.y - global_position.y)

		should_follow_player = distance_x <= DETECTION_RANGE_X and distance_y <= HEIGHT_TOLERANCE

		if should_follow_player and not is_shooting:
			if distance_x > SAFE_DISTANCE_X:
				run_towards_player()
			else:
				attack()
		else:
			patrol()   # Se o player não for detectado ou o inimigo não estiver atirando, patrulha

	move_and_slide()    # Movimento do inimigo

func attack():
	if abs(player.global_position.y - global_position.y) > HEIGHT_TOLERANCE:
		return    # Se o player estiver em outra altura, não atira

	velocity.x = 0
	is_shooting = true   # Evita múltiplos tiros ao mesmo tempo
	animated_sprite_2d.play("shot2")
	if is_instance_valid(tiro):
		tiro.play()
	await animated_sprite_2d.animation_finished
	shoot()

	is_shooting = false   # Libera para próximas ações
	animated_sprite_2d.play("idle")

func patrol():
	if is_shooting:
		return
	if is_instance_valid(patrulhando) and !patrulhando.playing:
		patrulhando.play()
	velocity.x = speed * direction
	animated_sprite_2d.play("walk")

	# Inverter direção se detectar parede à frente
	if wall_ray.is_colliding():
		direction *= -1
		update_direction()
		
func run_towards_player():
	direction = 1 if player.global_position.x > global_position.x else -1
	velocity.x = speed * direction * 1.5    # Corre mais rápido quando detecta o jogador
	flip()
	animated_sprite_2d.play("run")
	if is_instance_valid(correndo) and !correndo.playing:
		correndo.play()# Agora a animação de corrida sempre toca corretamente
		if is_instance_valid(patrulhando):
			patrulhando.stop()

func flip():
	animated_sprite_2d.flip_h = direction < 0
	gun.position.x = abs(gun.position.x) * direction

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = gun.global_position
	bullet.velocity = Vector2(600 * direction, 0)
	get_parent().add_child(bullet)

func take_damage(amount: int):
	if is_dead:
		return   # Não processa dano se já estiver morto
	health -= amount
	if health <= 0:
		die()
	else:
		if is_instance_valid(hurt):
			hurt.play()
		velocity = Vector2.ZERO
		is_shooting = true    # Bloqueia movimentos e ações enquanto "hurt"

		animated_sprite_2d.play("hurt")
		await animated_sprite_2d.animation_finished    # Espera a animação terminar

		await get_tree().create_timer(0.5).timeout    # Tempo extra para impacto

		is_shooting = false    # Libera os movimentos
		animated_sprite_2d.play("idle")


func die():
	if is_dead:
		return # Garante que die() seja executado apenas uma vez
	is_dead = true
	set_physics_process(false)
	velocity = Vector2.ZERO
	if is_instance_valid(animated_sprite_2d):
		animated_sprite_2d.play("dead")
	if is_instance_valid(morte):
		morte.play()
	Globals.score += 200
	await animated_sprite_2d.animation_finished
	dead_animation_finished = true
	queue_free()

func update_direction():
	animated_sprite_2d.flip_h = direction < 0
	gun.position.x = abs(gun.position.x) * direction
	wall_ray.target_position.x = 16 * direction
