extends CharacterBody2D

@export var speed: float = 100
@export var shooting_interval: float = 2.0
@export var health: int = 3
@export var jump_force: float = -300
@export var bullet_scene: PackedScene = preload("res://Prefabs/bullet_rider_1.tscn")

@onready var player = null
@onready var raycast: RayCast2D = $RayCast2D
@onready var ray_cast_2d_2: RayCast2D = $RayCast2D2
@onready var gun: Node2D = $Gun
@onready var animation := $Anim

var shooting_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_shooting := false
var should_follow_player := false

const DETECTION_RANGE_X = 500
const SHOOTING_RANGE_X = 300
const SAFE_DISTANCE_X = 100
const MAX_HEIGHT_DIFFERENCE = 50  # Tolerância de altura para evitar perseguição/tiros errados

func _ready():
	player = get_parent().get_node("Player")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if player:
		var distance_x = abs(player.global_position.x - global_position.x)
		var distance_y = abs(player.global_position.y - global_position.y)

		# O inimigo só detecta o jogador se estiver na mesma altura
		should_follow_player = distance_x <= DETECTION_RANGE_X and distance_y <= MAX_HEIGHT_DIFFERENCE

		# Só persegue se estiver dentro da área de detecção, na mesma altura e não estiver atirando
		if should_follow_player and not is_shooting and distance_x > SAFE_DISTANCE_X:
			var direction = (player.global_position - global_position).normalized()
			velocity.x = direction.x * speed
			flip()
		else:
			velocity.x = 0

		move_and_slide()

		# O inimigo só atira se o jogador estiver dentro do alcance X e na mesma altura
		if should_follow_player and distance_x <= SHOOTING_RANGE_X:
			shooting_timer -= delta
			if shooting_timer <= 0 and not is_shooting:
				shoot()
				shooting_timer = shooting_interval
		else:
			is_shooting = false  # Para o tiro se o jogador estiver longe ou em outra altura

	# **Evita que o inimigo continue se aproximando ao detectar o player**
	if raycast.is_colliding() and is_on_floor() or ray_cast_2d_2.is_colliding() and is_on_floor():
		var collider = raycast.get_collider()
		var collider2 = ray_cast_2d_2.get_collider()
		if collider or collider2 is TileMapLayer:
			velocity.y = jump_force  # Faz o inimigo pular
		else:
			velocity.x = 0  # Se não for um obstáculo, para de se mover

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
	is_shooting = true  # Para tudo enquanto atira
	should_follow_player = false  # Para de perseguir o player enquanto atira

	# Definir os ângulos de disparo para as balas
	var angles = [-10, 0, 10]  # A bala no centro (0°), uma para a esquerda (-10°) e uma para a direita (+10°)

	# Instancia as 3 balas
	for i in range(3):
		var bullet = bullet_scene.instantiate()

		# Define o offset para que as balas não saiam todas da mesma posição
		var offset = Vector2(30 * sign(velocity.x), 0) + Vector2(i * 10 - 10, 0)  # Ajuste o valor 10 conforme necessário para distribuir as balas
		bullet.position = gun.global_position + offset
		
		# Calcular a direção de cada bala com base nos ângulos
		var angle = deg_to_rad(angles[i])  # Converte o ângulo para radiano
		var direction = Vector2(cos(angle), sin(angle)).normalized()  # Calcula a direção com base no ângulo

		# Agora calculamos a direção para o player, independentemente da direção do rider_1
		var player_direction = (player.global_position - global_position).normalized()  # Direção do jogador
		direction.x = player_direction.x  # Direção das balas agora segue a direção do jogador, não do rider_1

		# Aplica a velocidade na direção
		bullet.velocity = direction * 600  # Velocidade das balas

		get_parent().add_child(bullet)  # Adiciona a bala ao jogo

	# Toca a animação de tiro
	animation.play("shot")
	await get_tree().create_timer(0.3).timeout  # Mantém a animação visível por 0.3s
	await animation.animation_finished

	is_shooting = false  # Permite que ele volte a se mover
	should_follow_player = abs(player.global_position.x - global_position.x) <= DETECTION_RANGE_X  # Só volta a seguir se o player ainda estiver perto
func take_damage(amount: int):
	health -= amount
	if health <= 0:
		animation.stop()
		animation.play("dead")
		await animation.animation_finished
		Globals.score += 300
		queue_free()
	else:
		animation.stop()
		animation.play("hurt")
		await get_tree().create_timer(0.5).timeout
