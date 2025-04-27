# Para um nó Control
extends Control

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_alerta: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var item_scene: PackedScene = preload("res://Prefabs/computer_screen.tscn")

func _ready():
	anim.visible = false
	# Conectar o sinal da forma correta
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.name == "Elias":
		anim.visible = true
		anim.play("alerta_computador")
		audio_alerta.play()
		show_screen()

func show_screen() -> void:
	if not item_scene:
		push_warning("item_scene não está definido!")
		return

	var screen_instance = item_scene.instantiate()
	screen_instance.global_position = global_position + Vector2(0, -20)
	get_tree().current_scene.add_child(screen_instance)
