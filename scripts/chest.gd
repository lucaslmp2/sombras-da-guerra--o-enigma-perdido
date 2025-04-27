extends Area2D

@export var item_scene: PackedScene  = preload("res://Prefabs/item.tscn")# Referência ao item
@onready var open_bau: AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_open = false

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("closed")

func _on_body_entered(body):
	if body.is_in_group("player") and not is_open:
		open_chest()

func open_chest():
	is_open = true
	open_bau.play()
	sprite.play("open")
	await sprite.animation_finished  # Espera a animação terminar
	spawn_item()

func spawn_item():
	if item_scene:
		var item_instance = item_scene.instantiate()
		if item_instance is Area2D:
			item_instance.global_position = global_position + Vector2(0, -40)
			get_parent().get_parent().add_child(item_instance) # Adiciona o pendrive à fase
			item_instance.add_to_group("pendrives")
			# Conecta o sinal à função _on_pendrive_coletado() no script da FASE
			item_instance.connect("pick_up_pendrive", Callable(get_parent().get_parent(), "_on_pendrive_coletado"))
			Globals.pen_drive = item_scene
			print(Globals.pen_drive)
		else:
			print("Erro: item_scene não é um Area2D!")
