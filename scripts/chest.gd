extends Area2D

@export var item_scene: PackedScene  # Referência para o item a ser criado

var is_open = false

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("closed")

func _on_body_entered(body):
	if body.is_in_group("player") and not is_open:
		open_chest()

func open_chest():
	is_open = true
	sprite.play("open")
	await sprite.animation_finished  # Espera a animação terminar
	spawn_item()

func spawn_item():
	if item_scene:  # Verifica se a cena do item está configurada
		var item_instance = item_scene.instantiate()  # Cria uma instância do item
		item_instance.global_position = global_position + Vector2(0, -20)  # Define a posição
		get_parent().add_child(item_instance)  # Adiciona o item na cena
