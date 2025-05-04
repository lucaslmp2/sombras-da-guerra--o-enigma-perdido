extends CharacterBody2D

# Nós Onready
@onready var collision: CollisionShape2D = $collision
@onready var correndo: AudioStreamPlayer2D = $correndo
@onready var pulo: AudioStreamPlayer2D = $pulo
@onready var morte: AudioStreamPlayer2D = $morte
@onready var hurt: AudioStreamPlayer2D = $hurt
@onready var anim: AnimatedSprite2D = $anim
@onready var porrada: AudioStreamPlayer2D = $porrada
@onready var wall_ray = $WallRay

# Parâmetros do Inimigo (ajuste conforme necessário)
const DETECTION_RANGE_X = 500     # Distância máxima para detectar o player no eixo X
const SAFE_DISTANCE_X = 50     # Distância mínima para parar de avançar
const HEIGHT_TOLERANCE = 10     # Margem de tolerância no eixo Y para considerar que estão na mesma altura
const ATTACK_RANGE_X = 20
@export var speed: float = 100
@export var direction: int = 1     # 1 para direita, -1 para esquerda
@onready var patrulhando: AudioStreamPlayer2D = $patrulhando
@export var health: int = 3 # Vida do inimigo

# Variáveis de Estado
var should_follow_player := false
var is_atacking := false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: Node2D = null
var is_dead := false # Adicionado para evitar chamadas de som após a morte
var current_attack_animation := 0 # Variável para controlar qual animação de ataque está sendo tocada
var attack_animations = ["atack_1", "atack_2", "atack_3"]


func _ready():
	# Busca o player na árvore de nós.  Isso é mais robusto.
	player = get_parent().get_node_or_null("Player")
	if is_instance_valid(patrulhando):
		patrulhando.play()
	update_direction()


func _physics_process(delta):
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var distance_x = INF
	var distance_y = INF

	if is_instance_valid(player):
		distance_x = abs(player.global_position.x - global_position.x)
		distance_y = abs(player.global_position.y - global_position.y)

		should_follow_player = distance_x <= DETECTION_RANGE_X and distance_y <= HEIGHT_TOLERANCE

		if should_follow_player and not is_atacking:
			if distance_x > ATTACK_RANGE_X: # Se estiver longe da distância de ataque, corre
				run_towards_player()
			else:
				attack() # Se estiver dentro da distância de ataque, ataca
		else:
			patrol()

	move_and_slide()
	

func patrol():
	if is_atacking:
		return
	if is_instance_valid(patrulhando) and !patrulhando.playing:
		patrulhando.play()
	velocity.x = speed * direction
	anim.play("walk")

	# Inverter direção se detectar parede à frente
	if wall_ray.is_colliding():
		direction *= -1
		update_direction()
	elif is_on_wall(): # Detecta colisão com paredes
		direction *= -1
		update_direction()


func attack():
	if abs(player.global_position.y - global_position.y) > HEIGHT_TOLERANCE:
		return     # Se o player estiver em outra altura, não atira

	velocity.x = 0
	is_atacking = true    # Evita múltiplos tiros ao mesmo tempo
	var attack_animation = attack_animations[current_attack_animation]
	anim.play(attack_animation)
	if is_instance_valid(porrada):
		porrada.play()
	await anim.animation_finished
	deal_damage() # Chama a função para causar dano
	is_atacking = false    # Libera para próximas ações
	anim.play("idle")
	current_attack_animation = (current_attack_animation + 1) % attack_animations.size()



func run_towards_player():
	direction = 1 if player.global_position.x > global_position.x else -1
	velocity.x = speed * direction * 1.5     # Corre mais rápido quando detecta o jogador
	update_direction() # Garante que a direção/flip esteja correta.
	anim.play("run")
	if is_instance_valid(correndo) and !correndo.playing:
		correndo.play()# Agora a animação de corrida sempre toca corretamente
		if is_instance_valid(patrulhando):
			patrulhando.stop() # PARE o áudio de patrulha aqui.
			
func update_direction():
	anim.flip_h = direction < 0
	wall_ray.target_position.x = 16 * direction

func take_damage(amount: int):
	if is_dead:
		return     # Não processa dano se já estiver morto

	health -= amount
	if health <= 0:
		die()
	else:
		if is_instance_valid(hurt):
			hurt.play()
		# Não zere a velocidade aqui a menos que você queira que o inimigo pare quando atingido
		# velocity = Vector2.ZERO
		anim.play("hurt") # Assumindo que "hurt" é a animação de dano
		await anim.animation_finished
		
func die():
	if is_dead:
		return
	is_dead = true
	set_physics_process(false) # Pare de mover
	velocity = Vector2.ZERO
	anim.play("dead")
	if is_instance_valid(morte):
		morte.play()
	if is_instance_valid(collision):
		call_deferred("desativar_collision_shape") # Adia a desativação da colisão
	await anim.animation_finished
	queue_free()

func desativar_collision_shape():
	if is_instance_valid(collision):
		collision.disabled = true
	
func deal_damage():
	# Implemente a lógica para causar dano ao jogador aqui
	if is_instance_valid(player) and player.has_method("take_damage"):
		player.take_damage(1)   
	pass
