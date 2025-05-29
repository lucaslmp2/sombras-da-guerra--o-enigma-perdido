extends CharacterBody2D
var move_speed := 50
var direction := 1
var health := 3
var can_shoot := true
var is_shooting_animation_playing := false
var is_taking_damage := false # Novo: Para controlar o estado de dano
var is_dead := false # Novo: Para controlar o estado de morte

@export var fire_rate := 1.0 # Intervalo entre os disparos em segundos
@export var shot_animation_duration := 0.2 # Duração da animação de disparo em segundos

@export var item_scene: PackedScene = preload("res://Prefabs/chave_gaiola.tscn")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var shot_marker: Marker2D = $Shot_marker
@onready var ground_detector: RayCast2D = $ground_detector
@onready var player_detector: RayCast2D = $player_detector
@onready var fire_timer: Timer = $FireTimer
@onready var shot_animation_timer: Timer = $ShotAnimationTimer

var original_shot_marker_position: Vector2
const bullet = preload("res://Prefabs/bullet_rider_1.tscn")

@onready var hurt_sound: AudioStreamPlayer2D = $hurt # Renomeado para clareza
@onready var dead_sound: AudioStreamPlayer2D = $dead # Renomeado para clareza
@onready var walk_sound: AudioStreamPlayer2D = $walk # Renomeado para clareza
@onready var run_sound: AudioStreamPlayer2D = $run # Renomeado para clareza
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
	# Se o inimigo estiver morto ou recebendo dano, não deve se mover ou atirar
	if is_dead or is_taking_damage:
		velocity.x = 0
		move_and_slide()
		return # Sai da função para não executar o resto do código

	if is_on_wall():
		direction *= -1
		animated_sprite_2d.scale.x *= -1
		player_detector.scale.x *= -1
		shot_marker.position.x = original_shot_marker_position.x * sign(animated_sprite_2d.scale.x)

	if not ground_detector.is_colliding():
		animated_sprite_2d.scale.x *= -1
		player_detector.scale.x *= -1
		direction *= -1
		shot_marker.position.x = original_shot_marker_position.x * sign(animated_sprite_2d.scale.x)

	# Lógica de disparo
	if player_detector.is_colliding() and can_shoot and not is_shooting_animation_playing:
		animated_sprite_2d.play("shot")
		shot()
		can_shoot = false
		is_shooting_animation_playing = true
		fire_timer.start()
		shot_animation_timer.start()
	# Lógica de animação de caminhada/ocioso
	elif not is_shooting_animation_playing and not is_taking_damage: # Garante que não toca walk se estiver hurt
		if is_on_floor() and velocity.length() > 0:
			if animated_sprite_2d.animation != "walk":
				animated_sprite_2d.play("walk")
			if not walk_sound.playing:
				walk_sound.play()
		elif velocity.length() == 0 or not is_on_floor():
			if animated_sprite_2d.animation != "idle": # Adicione uma animação de "idle" se tiver
				animated_sprite_2d.play("idle")
			if walk_sound.playing:
				walk_sound.stop()


	velocity.x = move_speed * direction
	move_and_slide()

func shot():
	var new_bullet = bullet.instantiate()
	new_bullet.global_position = shot_marker.global_position
	if sign(animated_sprite_2d.scale.x) == 1:
		new_bullet.velocity = Vector2(300, 0)
	else:
		new_bullet.velocity = Vector2(-300, 0)
	get_parent().add_child(new_bullet) # Use get_parent().add_child para adicionar a cena corretamente
	shot_sound.play()

func take_damage(damage_amount: int) -> void:
	if is_dead or is_taking_damage: # Impede dano se já estiver morto ou recebendo dano
		return

	health -= damage_amount
	is_taking_damage = true # Define o estado de dano

	hurt_sound.play()
	animated_sprite_2d.play("hurt")

	await animated_sprite_2d.animation_finished # Espera a animação de hurt terminar

	if health <= 0:
		die()
		if not is_dead: # Garante que a morte só aconteça uma vez
			is_dead = true
			Globals.score += 100
			dead_sound.play()
			animated_sprite_2d.play("dead")
			# Desativa a colisão do inimigo para evitar mais dano e que o player trave nele
			set_physics_process(false) # Para o processamento físico
			set_process(false) # Para o processamento regular (se necessário)
			# Desativa o CollisionShape2D
			for child in get_children():
				if child is CollisionShape2D:
					(child as CollisionShape2D).set_deferred("disabled", true)

			await animated_sprite_2d.animation_finished # Espera a animação de dead terminar
			queue_free()
	else:
		is_taking_damage = false # Reseta o estado de dano se o inimigo ainda estiver vivo
func die():
	if is_dead:
		return
	var chave = preload("res://Prefabs/chave_gaiola.tscn").instantiate()
	chave.position = position
	get_tree().current_scene.add_child(chave)  # Adiciona à fase atual
	
func _on_fire_timer_timeout():
	can_shoot = true

func _on_shot_animation_timer_timeout():
	is_shooting_animation_playing = false
