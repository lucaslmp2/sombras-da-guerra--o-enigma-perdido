extends CharacterBody2D
@onready var player_collision: Area2D = $PlayerCollision
var shots_remaining: int = 0
var triggered_run_away: bool = false
var is_special_attack: bool = false
@export var gravity: float = 600.0

@onready var animation: AnimatedSprite2D = $Anim
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var gun_position: Marker2D = $GunPosition # Ponto de onde a bala sai
@export var move_speed: float = 50.0
@export var patrol_distance: float = 100.0
@export var idle_time_min: float = 3.0
@export var idle_time_max: float = 5.0
@export var shot_cooldown: float = 1.0
@export var recharge_time: float = 2.0
@export var bullet_scene: PackedScene # Cene da bala a ser instanciada
@export var run_away_speed: float = 100.0
@export var run_away_door_position: Vector2 # Posição da porta para fugir
@export var detection_range: float = 100.0
@onready var tiro: AudioStreamPlayer2D = $tiro
@onready var andar: AudioStreamPlayer2D = $andar
@onready var correr: AudioStreamPlayer2D = $correr
@onready var dano: AudioStreamPlayer2D = $dano
@onready var morte: AudioStreamPlayer2D = $morte
@onready var recarregar: AudioStreamPlayer2D = $recarregar


enum State {
	PATROLLING,
	IDLE,
	CHASING,
	SHOOTING,
	RECHARGING,
	RUNNING_AWAY
}

var current_state: State = State.PATROLLING
var patrol_direction: int = 1 # 1 para direita, -1 para esquerda
var patrol_start_position: Vector2
var idle_timer: float = 0.0
var shot_timer: float = 0.0
var recharging_timer: float = 0.0
var player: Node2D = null
var can_shoot: bool = true

func _ready():
	patrol_start_position = global_position
	_change_state(State.PATROLLING)
	patrol_start_position = global_position
	player_collision.connect("body_entered", Callable(self, "_on_player_collision"))
	_change_state(State.PATROLLING)

func _on_player_collision(body):
	if body.is_in_group("player") and not triggered_run_away:
		player = body
		shots_remaining = 3
		triggered_run_away = true
		is_special_attack = true

		# 👉 Faz o inimigo olhar para o jogador
		if player.global_position.x > global_position.x:
			animation.flip_h = false
			player_detector.target_position = Vector2(detection_range, 0)
			gun_position.position.x = abs(gun_position.position.x)
		else:
			animation.flip_h = true
			player_detector.target_position = Vector2(-detection_range, 0)
			gun_position.position.x = -abs(gun_position.position.x)

		_change_state(State.SHOOTING)



func _physics_process(delta):
	match current_state:
		State.PATROLLING:
			_patrol(delta)
		State.IDLE:
			_idle(delta)
		State.CHASING:
			_chase(delta)
		State.SHOOTING:
			_shoot(delta)
		State.RECHARGING:
			_recharge(delta)
		State.RUNNING_AWAY:
			_run_away(delta)

	_detect_player() # Chama a função de detecção do jogador a cada frame físico

	velocity.y += gravity * delta
	move_and_slide()


@onready var sprite: AnimatedSprite2D = $Anim # Garante que temos uma referência ao AnimatedSprite2D

func _patrol(delta):
	velocity.x = move_speed * patrol_direction
	if patrol_direction == 1:
		animation.flip_h = false
		player_detector.target_position = Vector2(detection_range, 0)
		gun_position.position.x = abs(gun_position.position.x) # Garante posição positiva X
	else:
		animation.flip_h = true
		player_detector.target_position = Vector2(-detection_range, 0)
		gun_position.position.x = -abs(gun_position.position.x) # Garante posição negativa X

	if global_position.x > patrol_start_position.x + patrol_distance and patrol_direction == 1:
		_change_state(State.IDLE)
	elif global_position.x < patrol_start_position.x - patrol_distance and patrol_direction == -1:
		_change_state(State.IDLE)

func _chase(delta):
	if is_instance_valid(player):
		if player.global_position.x > global_position.x:
			velocity.x = move_speed
			animation.flip_h = false
			player_detector.target_position = Vector2(detection_range, 0)
			gun_position.position.x = abs(gun_position.position.x) # Garante posição positiva X
		else:
			velocity.x = -move_speed
			animation.flip_h = true
			player_detector.target_position = Vector2(-detection_range, 0)
			gun_position.position.x = -abs(gun_position.position.x) # Garante posição negativa X

		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player < 400 and can_shoot:
			_change_state(State.SHOOTING)
	else:
		_change_state(State.PATROLLING) # Se o jogador sumir, volta a patrulhar

func _change_state(new_state: State):
	current_state = new_state
	match current_state:
		State.PATROLLING:
			animation.play("walk")
			andar.play()
		State.IDLE:
			animation.play("idle")
			idle_timer = randf_range(idle_time_min, idle_time_max)
			# Manter a direção da animação ao entrar em IDLE
			if velocity.x > 0:
				animation.flip_h = false
			elif velocity.x < 0:
				animation.flip_h = true
			velocity.x = 0 # Zera a velocidade ao entrar em IDLE
		State.CHASING:
			animation.play("run")
			correr.play()
		State.SHOOTING:
			animation.play("shot")
			tiro.play()
			shot_timer = shot_cooldown
			can_shoot = false
			velocity = Vector2.ZERO # Zera a velocidade ao entrar no estado de SHOOTING
		State.RECHARGING:
			animation.play("recharge")
			recarregar.play()
			recharging_timer = recharge_time
		State.RUNNING_AWAY:
			animation.play("run")
			correr.play()

func _idle(delta):
	idle_timer -= delta
	if player != null:
		_change_state(State.CHASING)
	elif idle_timer <= 0:
		patrol_direction *= -1
		animation.flip_h = !animation.flip_h
		_change_state(State.PATROLLING)

func _shoot(delta):
	if shot_timer <= 0:
		if is_instance_valid(player):
			var bullet = bullet_scene.instantiate()
			bullet.global_position = gun_position.global_position
			var shoot_direction = Vector2.RIGHT
			if animation.flip_h:
				shoot_direction = Vector2.LEFT

			bullet.velocity = shoot_direction * 400.0
			get_parent().add_child(bullet)

			tiro.play()
			shot_timer = shot_cooldown
			shots_remaining -= 1

			if is_special_attack:
				if shots_remaining > 0:
					_change_state(State.RECHARGING)
				else:
					is_special_attack = false
					_change_state(State.RUNNING_AWAY)
			else:
				_change_state(State.RECHARGING)
		else:
			_change_state(State.PATROLLING)
	else:
		shot_timer -= delta

func _recharge(delta):
	recharging_timer -= delta
	if recharging_timer <= 0:
		can_shoot = true
		if is_instance_valid(player):
			if is_special_attack and shots_remaining > 0:
				_change_state(State.SHOOTING)
			else:
				_change_state(State.CHASING)
		else:
			_change_state(State.PATROLLING)


func _run_away(delta):
	if global_position.distance_to(run_away_door_position) > 5:
		var direction_to_door = (run_away_door_position - global_position).normalized()
		velocity = direction_to_door * run_away_speed
		animation.flip_h = velocity.x < 0
	else:
		queue_free()

func _detect_player():
	if player_detector.is_colliding():
		var collider = player_detector.get_collider()
		if collider.is_in_group("player"):
			player = collider
			if current_state == State.PATROLLING or current_state == State.IDLE:
				_change_state(State.CHASING)
	else:
		if current_state == State.CHASING:
			player = null
			_change_state(State.PATROLLING)
