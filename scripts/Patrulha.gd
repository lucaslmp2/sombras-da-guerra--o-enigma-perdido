extends CharacterBody2D
const DETECTION_RANGE_X = 500  # Distância máxima para detectar o player no eixo X
@onready var character_body_2d: CharacterBody2D = $"."
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gun: Node2D = $Gun
@export var direction: int = 1  # 1 para direita, -1 para esquerda
@export var speed: float = 50
@export var detection_range: float = 300
@export var attack_range: float = 50  # Distância para parar perto do jogador
@export var health: int = 5  # Vida do inimigo
@export var bullet_scene : PackedScene = preload("res://Prefabs/bullet_rider_1.tscn")
var player: Node2D = null
var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
const SAFE_DISTANCE_X = 100  # Distância mínima para parar de avançar
var is_shooting := false  # Controla se o inimigo está atirando
var should_follow_player := false  # Define se o inimigo pode seguir
func _ready():
	player = get_parent().get_node("Player")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	var distance_x = INF  # Define um valor alto inicial para evitar erros

	if player:
		distance_x = abs(player.global_position.x - global_position.x)
		should_follow_player = distance_x <= DETECTION_RANGE_X

	# Só persegue se estiver dentro da área de detecção e não estiver atirando
	if should_follow_player and not is_shooting and distance_x > SAFE_DISTANCE_X:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
		flip()
	else:
		velocity.x = 0  # Para completamente se estiver longe, atirando ou muito perto

	move_and_slide()

func attack():
	velocity.x = 0
	animated_sprite_2d.play("shot")
	await animated_sprite_2d.animation_finished
	shoot()
	animated_sprite_2d.play("idle")


func patrol():
	velocity.x = speed * direction
	if is_on_wall():
		direction *= -1
		flip()
	animated_sprite_2d.play("walk")

func run_towards_player():
	direction = 1 if player.global_position.x > global_position.x else -1
	velocity.x = speed * direction * 1.5  # Corre ligeiramente mais rápido ao detectar o jogador
	flip()
	animated_sprite_2d.play("run")

func stop_and_idle():
	velocity.x = 0
	animated_sprite_2d.play("idle")

func flip():
	animated_sprite_2d.flip_h = direction < 0
	gun.position.x = abs(gun.position.x) * direction

func shoot():
	animated_sprite_2d.play("shot")
	var bullet = bullet_scene.instantiate()
	bullet.position = gun.global_position
	bullet.velocity = Vector2(600 * direction, 0)  # Movimento apenas na horizontal
	get_parent().add_child(bullet)
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()
	else:
		velocity = Vector2.ZERO  # Para de se mover durante o dano
		animated_sprite_2d.play("hurt")
		
		# Aguarda um pequeno tempo para garantir que a animação seja visível
		await get_tree().create_timer(0.3).timeout  

		animated_sprite_2d.play("idle")  # Volta para idle após o dano


func die():
	set_physics_process(false)  # Desativa movimentação
	velocity = Vector2.ZERO  # Para de se mover
	animated_sprite_2d.play("dead")
	await animated_sprite_2d.animation_finished
	queue_free()  # Remove o inimigo corretamente
