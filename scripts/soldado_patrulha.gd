extends CharacterBody2D
var move_speed := 50
var direction := 1
var health := 3
var can_shoot := true
var is_shooting_animation_playing := false
@export var fire_rate := 1.0 # Intervalo entre os disparos em segundos
@export var shot_animation_duration := 0.2 # Duração da animação de disparo em segundos
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shot_marker: Marker2D = $Shot_marker
@onready var ground_detector: RayCast2D = $ground_detector
@onready var player_detector: RayCast2D = $player_detector
@onready var fire_timer: Timer = $FireTimer
@onready var shot_animation_timer: Timer = $ShotAnimationTimer
var original_shot_marker_position: Vector2
const bullet = preload("res://Prefabs/bullet_rider_1.tscn")
@onready var hurt: AudioStreamPlayer2D = $hurt
@onready var dead: AudioStreamPlayer2D = $dead
@onready var walk: AudioStreamPlayer2D = $walk
@onready var run: AudioStreamPlayer2D = $run
@onready var shot_sound: AudioStreamPlayer2D = $shot

func _ready() -> void:
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	shot_animation_timer.wait_time = shot_animation_duration
	shot_animation_timer.one_shot = true
	shot_animation_timer.timeout.connect(_on_shot_animation_timer_timeout)
	original_shot_marker_position = shot_marker.position

func _physics_process(delta: float) -> void:
	if is_on_wall():
		direction *= -1
		animated_sprite_2d.scale.x *= -1
		player_detector.scale.x *= -1
		# Ajusta a posição do Shot_marker ao flipar
		shot_marker.position.x = original_shot_marker_position.x * sign(animated_sprite_2d.scale.x)

	if not ground_detector.is_colliding():
		animated_sprite_2d.scale.x *= -1
		player_detector.scale.x *= -1
		direction *= -1
		# Ajusta a posição do Shot_marker ao flipar
		shot_marker.position.x = original_shot_marker_position.x * sign(animated_sprite_2d.scale.x)

	if player_detector.is_colliding() and can_shoot and not is_shooting_animation_playing:
		animated_sprite_2d.play("shot")
		shot()
		can_shoot = false
		is_shooting_animation_playing = true
		fire_timer.start()
		shot_animation_timer.start()
	elif not is_shooting_animation_playing and is_on_floor() and velocity.length() > 0 and animated_sprite_2d.animation != "walk":
		animated_sprite_2d.play("walk")
		if not walk.playing:
			walk.play()
	elif velocity.length() == 0 or not is_on_floor():
		if walk.playing:
			walk.stop()
	elif not is_shooting_animation_playing and animated_sprite_2d.animation == "walk" and not walk.playing and is_on_floor() and velocity.length() > 0:
		walk.play()

	velocity.x = move_speed * direction
	move_and_slide()

func shot():
	var new_bullet = bullet.instantiate()
	new_bullet.global_position = shot_marker.global_position
	if sign(animated_sprite_2d.scale.x) == 1:
		new_bullet.velocity = Vector2(300, 0)
	else:
		new_bullet.velocity = Vector2(-300, 0)
	add_sibling(new_bullet)
	shot_sound.play() # Toca o som de disparo

func take_damage(damage_amount: int) -> void:
	health -= damage_amount
	hurt.play() # Toca o som de dano
	if health <= 0:
		dead.play() # Toca o som de morte
		queue_free() # Destrói o inimigo

func _on_fire_timer_timeout():
	can_shoot = true

func _on_shot_animation_timer_timeout():
	is_shooting_animation_playing = false
