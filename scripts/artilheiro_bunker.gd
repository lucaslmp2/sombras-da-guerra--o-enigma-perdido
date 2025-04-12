extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var bullet_scene = preload("res://Prefabs/bullet_bunker_strike.tscn")

var shooting = false
@export var fire_rate: float = 0.1  # Intervalo entre disparos
@export var burst_count: int = 7  # Disparar 7 vezes em rajada
@export var spawn_offset: Vector2 = Vector2(-20, -12)  # 10px acima

var bullet_count: int = 0
@export var health: int = 3  # Vida do artilheiro

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	if health > 0 and ray_cast_2d.is_colliding():
		var target = ray_cast_2d.get_collider()
		# Adicionando uma verificação para garantir que 'target' não seja nulo
		if target != null and target.is_in_group("player") and not shooting:
			start_shooting()
	else:
		stop_shooting()

func start_shooting():
	if health <= 0:
		stop_shooting() # Garante que não comece a atirar se já estiver morto
		return
	shooting = true
	shoot_burst()

func stop_shooting():
	shooting = false
	if health > 0:
		animated_sprite_2d.play("idle") # Volta para a animação idle se ainda estiver vivo

func shoot_burst():
	if not shooting or health <= 0:
		animated_sprite_2d.play("idle")
		shooting = false # Garante que a flag de shooting seja desligada
		return

	var origin = global_position + spawn_offset

	var target_direction = Vector2.RIGHT
	if ray_cast_2d.is_colliding():
		var collision = ray_cast_2d.get_collider()
		# Adicionando uma verificação para garantir que houve uma colisão válida
		if collision != null:
			target_direction = (ray_cast_2d.get_collision_point() - origin).normalized()

	for i in range(burst_count):
		if not shooting or health <= 0:
			break

		animated_sprite_2d.play("shot")

		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = origin

		bullet.set_velocity(target_direction)

		await get_tree().create_timer(fire_rate).timeout

	if shooting and health > 0:
		shoot_burst()

func _on_body_entered(body):
	if body.is_in_group("bullet"):
		take_damage(1)

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()
	else:
		animated_sprite_2d.play("idle")

func die():
	health = 0
	shooting = false
	animated_sprite_2d.play("dead")
	Globals.score += 200
	await animated_sprite_2d.animation_finished
	queue_free()
