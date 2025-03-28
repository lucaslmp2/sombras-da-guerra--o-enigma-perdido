extends CharacterBody2D

@export var speed : float = 100
@export var shooting_interval : float = 2.0
@onready var player = null
@export var bullet_scene : PackedScene = preload("res://Prefabs/Bullet.tscn")
@export var health : int = 3
@export var jump_force : float = -600 # Força do pulo
@onready var raycast : RayCast2D = $RayCast2D # Adiciona o RayCast2D

var shooting_timer : float = 0.0
var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	player = get_parent().get_node("Player")

func _physics_process(delta):
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed # Ajuste para usar apenas direção horizontal
		flip()
		move_and_slide()
		shooting_timer -= delta
		if shooting_timer <= 0:
			shoot()
			shooting_timer = shooting_interval

		# Pulo automático com RayCast2D
		if raycast.is_colliding() and is_on_floor():
			var collider = raycast.get_collider()
			if collider is TileMapLayer: # Verifica se o colisor é um TileMap
				velocity.y = jump_force

func flip():
	if velocity.x > 0:
		$Anim.flip_h = false
		$Anim.play("run")
		# Ajusta a posição do RayCast2D para a direita
		raycast.position.x = abs(raycast.position.x)
	elif velocity.x < 0:
		$Anim.flip_h = true
		$Anim.play("run")
		# Ajusta a posição do RayCast2D para a esquerda
		raycast.position.x = -abs(raycast.position.x)

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = global_position
	bullet.set_velocity((player.global_position - global_position).normalized() * 600) # Use set_velocity()
	get_parent().add_child(bullet)

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()
