extends RigidBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var explosion_scene: PackedScene = preload("res://Prefabs/explosion.tscn")
var collision_count := 0
var max_collisions := 3
var damage := 3

func _ready():
	await get_tree().create_timer(3.0).timeout # Delay de 3 segundos antes de explodir
	explode()

func throw_grenade(direction: Vector2):
	var speed = 200 # Ajuste a velocidade do lançamento conforme necessário
	linear_velocity = direction * speed
	apply_impulse(direction * speed)

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		#body.take_damage(damage) # O dano agora será aplicado pela área de explosão
		collision_count += 1
		if collision_count >= max_collisions:
			explode()

func _on_area_entered(area):
	if area.is_in_group("enemy"):
		#area.take_damage(damage) # O dano agora será aplicado pela área de explosão
		explode()

func explode():
	animated_sprite.play("explosion") # Toca a animação da explosão
	await animated_sprite.animation_finished # Espera a animação terminar
	if explosion_scene:
		var explosion_instance = explosion_scene.instantiate()
		explosion_instance.global_position = global_position
		explosion_instance.damage = damage # Passa o dano para a cena de explosão
		get_parent().add_child(explosion_instance)
	queue_free() # Remove a granada da cena
