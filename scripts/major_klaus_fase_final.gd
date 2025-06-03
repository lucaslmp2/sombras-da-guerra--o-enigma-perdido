extends CharacterBody2D
signal liberar_porta()
# --- Node References ---
@onready var animation: AnimatedSprite2D = $Anim
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var gun_position: Marker2D = $GunPosition # Ponto de onde a bala sai

# --- Sound References ---
@onready var tiro: AudioStreamPlayer2D = $tiro
@onready var andar: AudioStreamPlayer2D = $andar
@onready var correr: AudioStreamPlayer2D = $correr # Pode ser removido se não houver animação de "correr"
@onready var dano: AudioStreamPlayer2D = $dano
@onready var morte: AudioStreamPlayer2D = $morte
@onready var recarregar: AudioStreamPlayer2D = $recarregar

# --- Movement Properties ---
@export var gravity: float = 600.0
@export var move_speed: float = 50.0
@export var patrol_distance: float = 100.0

# --- Timers & Cooldowns ---
@export var idle_time_min: float = 3.0
@export var idle_time_max: float = 5.0
@export var shot_cooldown: float = 1.0 # Tempo entre disparos
@export var recharge_time: float = 2.0 # Tempo para recarregar após disparar

# --- Enemy Specific Properties ---
@export var health: int = 10 # VIDA DO INIMIGO: Definido para 10
@export var bullet_scene: PackedScene # Cena da bala a ser instanciada
@export var detection_range: float = 100.0 # Alcance do PlayerDetector

# --- Internal State Variables ---
var patrol_direction: int = 1 # 1 para direita, -1 para esquerda
var patrol_start_position: Vector2
var idle_timer: float = 0.0
var shot_timer: float = 0.0
var recharging_timer: float = 0.0
var player: Node2D = null
var can_shoot: bool = true
var is_dead := false # Novo: Para controlar o estado de morte
var is_taking_damage := false # Novo: Para controlar o estado de dano

enum State {
	PATROLLING,
	IDLE,
	SHOOTING,
	RECHARGING
}

var current_state: State = State.PATROLLING

func _ready():
	patrol_start_position = global_position
	_change_state(State.PATROLLING)
	
	# Garante que o detector esteja na direção correta no início
	if animation.flip_h:
		player_detector.target_position = Vector2(-detection_range, 0)
		gun_position.position.x = -abs(gun_position.position.x)
	else:
		player_detector.target_position = Vector2(detection_range, 0)
		gun_position.position.x = abs(gun_position.position.x)


func _physics_process(delta):
	# Se o inimigo estiver morto, não processa mais nada
	if is_dead:
		return

	# Aplica gravidade se não estiver no chão
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Se estiver recebendo dano, não processa o movimento ou outras ações
	if is_taking_damage:
		velocity.x = 0
		move_and_slide()
		return

	# Lógica de estados
	match current_state:
		State.PATROLLING:
			_patrol(delta)
		State.IDLE:
			_idle(delta)
		State.SHOOTING:
			_shoot(delta)
		State.RECHARGING:
			_recharge(delta)

	_detect_player() # Chama a função de detecção do jogador a cada frame físico

	move_and_slide() # Movimento do inimigo


func _patrol(delta):
	velocity.x = move_speed * patrol_direction
	animation.play("walk")
	if is_instance_valid(andar) and not andar.playing: # Toca som de andar
		andar.play()

	_update_direction_and_sprite() # Atualiza direção e sprite

	# Inverter direção se atingir o limite de patrulha
	if (patrol_direction == 1 and global_position.x > patrol_start_position.x + patrol_distance) or \
	   (patrol_direction == -1 and global_position.x < patrol_start_position.x - patrol_distance):
		_change_state(State.IDLE)


func _change_state(new_state: State):
	current_state = new_state
	# Para o som de andar ao mudar de estado
	if is_instance_valid(andar) and andar.playing:
		andar.stop()

	match current_state:
		State.PATROLLING:
			animation.play("walk")
			# O som de andar será iniciado no _patrol
		State.IDLE:
			animation.play("idle")
			idle_timer = randf_range(idle_time_min, idle_time_max)
			velocity.x = 0 # Zera a velocidade ao entrar em IDLE
		State.SHOOTING:
			animation.play("shot")
			if is_instance_valid(tiro):
				tiro.play()
			shot_timer = shot_cooldown
			can_shoot = false
			velocity.x = 0 # Zera a velocidade ao entrar no estado de SHOOTING
		State.RECHARGING:
			animation.play("recharge")
			if is_instance_valid(recarregar):
				recarregar.play()
			recharging_timer = recharge_time
			velocity.x = 0 # Zera a velocidade ao recarregar

func _idle(delta):
	idle_timer -= delta
	if idle_timer <= 0:
		patrol_direction *= -1
		_update_direction_and_sprite() # Atualiza direção e sprite
		_change_state(State.PATROLLING)

func _shoot(delta):
	if shot_timer <= 0:
		if is_instance_valid(player):
			var bullet = bullet_scene.instantiate()
			bullet.global_position = gun_position.global_position
			
			var shoot_direction_vector = Vector2.RIGHT if not animation.flip_h else Vector2.LEFT
			bullet.velocity = shoot_direction_vector * 400.0 # Velocidade da bala
			get_parent().add_child(bullet)

			if is_instance_valid(tiro):
				tiro.play()
			
			_change_state(State.RECHARGING) # Transiciona para recarregar após o tiro
		else:
			_change_state(State.PATROLLING) # Se o player sumiu, volta a patrulhar
	else:
		shot_timer -= delta


func _recharge(delta):
	recharging_timer -= delta
	if recharging_timer <= 0:
		can_shoot = true
		if is_instance_valid(player) and player_detector.is_colliding(): # Se o player ainda estiver visível
			_change_state(State.SHOOTING)
		else:
			_change_state(State.PATROLLING)


func _detect_player():
	if player_detector.is_colliding():
		var collider = player_detector.get_collider()
		if collider.is_in_group("player"):
			player = collider
			# Se detectar o player e não estiver atirando ou recarregando, muda para atirar
			if current_state != State.SHOOTING and current_state != State.RECHARGING:
				# Vira para o player antes de atirar
				if player.global_position.x > global_position.x:
					animation.flip_h = false
					patrol_direction = 1
				else:
					animation.flip_h = true
					patrol_direction = -1
				_update_direction_and_sprite() # Garante que a arma e o detector viram também
				_change_state(State.SHOOTING)
	else:
		# Se o player não for mais detectado e estava atirando/recarregando, volta a patrulhar
		if current_state == State.SHOOTING or current_state == State.RECHARGING:
			player = null
			_change_state(State.PATROLLING)


func take_damage(amount: int):
	if is_dead or is_taking_damage: # Não recebe dano se já estiver morto ou no estado de dano
		return

	health -= amount
	is_taking_damage = true # Define o estado de "recebendo dano"

	if is_instance_valid(dano):
		dano.play()
	if is_instance_valid(animation):
		animation.play("hurt") # Assumindo que você tem uma animação "dano" ou "hurt"
		await animation.animation_finished # Espera a animação de dano terminar

	if health <= 0:
		_die()
	else:
		is_taking_damage = false # Sai do estado de "recebendo dano" se ainda estiver vivo
		# Opcional: Voltar para um estado anterior ou manter o estado atual
		# Para simplicidade, o inimigo apenas para de receber dano e continua sua lógica
		# Se você quiser que ele volte para um estado específico (ex: PATROLLING/SHOOTING)
		# após levar dano, adicione a lógica aqui.

func _die():
	if is_dead: # Garante que a função de morte só seja chamada uma vez
		return
	is_dead = true
	
	# Para processamento físico e regular
	set_physics_process(false)
	set_process(false)
	velocity = Vector2.ZERO # Garante que ele pare completamente

	if is_instance_valid(morte):
		morte.play()
	
	if is_instance_valid(animation):
		animation.play("dead") # Toca a animação de morte
		# Espera um tempo fixo após tocar a animação de morte, como no seu exemplo
		await get_tree().create_timer(0.3).timeout 

	# Desabilita as formas de colisão
	for child in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", true)
		elif child is CollisionPolygon2D:
			(child as CollisionPolygon2D).set_deferred("disabled", true) # Para colisões de polígonos

	# Opcional: Atualizar pontuação global se você tiver um singleton Globals
	# if "Globals" in self and Globals.has_method("add_score"):
	#     Globals.add_score(200)
	emit_signal("liberar_porta")
	# Espera um tempo antes de remover o inimigo da cena
	await get_tree().create_timer(1.0).timeout # Espera 1 segundo (ajuste conforme necessário)
	queue_free() # Remove o nó da cena

func _update_direction_and_sprite():
	# Atualiza a direção do sprite
	animation.flip_h = (patrol_direction == -1)
	
	# Atualiza a direção do player_detector e gun_position
	if patrol_direction == 1:
		player_detector.target_position = Vector2(detection_range, 0)
		gun_position.position.x = abs(gun_position.position.x)
	else:
		player_detector.target_position = Vector2(-detection_range, 0)
		gun_position.position.x = -abs(gun_position.position.x)
