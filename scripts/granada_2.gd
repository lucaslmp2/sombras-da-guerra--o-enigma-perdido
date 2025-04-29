extends RigidBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var explosion_scene: PackedScene = preload("res://Prefabs/explosion.tscn")
var collision_count := 0
var max_collisions := 3
var damage := 3
@onready var explosão: AudioStreamPlayer2D = $explosão
@onready var rolando_no_chão: AudioStreamPlayer2D = $rolando_no_chão
var is_rolling := false # Variável para controlar se a granada está rolando
var has_exploded := false # Variável para garantir que a explosão ocorra apenas uma vez
var time_to_explode := 3.0 # Variável para armazenar o tempo até a explosão
var timer := 0.0 # Variável para controlar a contagem do tempo

func _ready():
	rolando_no_chão.play()
	is_rolling = true
	time_to_explode = 3.0
	timer = 0.0

func _physics_process(delta):
	timer += delta # Incrementa o timer com o delta
	# Se a granada estiver se movendo e o som não estiver tocando, comece a tocar
	if linear_velocity.length() > 10 && !rolando_no_chão.playing && is_rolling:
		rolando_no_chão.play()
	# Se a granada estiver parada ou quase parada, pare o som
	elif linear_velocity.length() <= 10:
		rolando_no_chão.stop()
		is_rolling = false

	if timer >= time_to_explode: # Verifica se o tempo de explosão passou
		explode()

func throw_grenade(direction: Vector2):
	var speed = 200 # Ajuste a velocidade do lançamento conforme necessário
	linear_velocity = direction * speed
	apply_impulse(direction * speed)
	# Chamando explode() após o lançamento da granada
	# explode() # Removendo a chamada para explode() daqui

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		#body.take_damage(damage) # O dano agora será aplicado pela área de explosão
		collision_count += 1
		if collision_count >= max_collisions:
			explode()
	if !is_rolling:
		rolando_no_chão.play()
		is_rolling = true

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		#body.take_damage(damage) # O dano agora será aplicado pela área de explosão
		explode()

func explode():
	if has_exploded: # Verifica se a explosão já ocorreu
		return
	has_exploded = true # Define como verdadeiro para garantir que a explosão ocorra apenas uma vez
	explosão.play() # Toca o som da explosão

	if is_rolling:
		rolando_no_chão.stop()
	animated_sprite.play("explosion") # Toca a animação da explosão
	await animated_sprite.animation_finished # Espera a animação terminar
	if explosion_scene:
		var explosion_instance = explosion_scene.instantiate()
		explosion_instance.global_position = global_position
		explosion_instance.damage = damage # Passa o dano para a cena de explosão
		get_parent().add_child(explosion_instance)
	queue_free() # Remove a granada da cena
