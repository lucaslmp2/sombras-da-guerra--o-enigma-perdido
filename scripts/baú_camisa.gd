extends Area2D
@export var item_scene: PackedScene = preload("res://Prefabs/blusa.tscn")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var chest_open: AudioStreamPlayer2D = $chest_open
@onready var chest_close: AudioStreamPlayer2D = $chest_close
const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
@onready var hud: CanvasLayer = get_node("/root/Fase_3/HUD")
signal camisa_coletada
var dialog_data2: Dictionary = {
	0: {
		"faceset": "res://Assets/Prontos/face aset elias2 sorrindo.png",
		"dialog": "Um novo baú.",
		"title": "Elias"
	},
	1: {
		"faceset": "res://Assets/Prontos/face aset elias2 sorrindo.png",
		"dialog": "O que será que tem agora?",
		"title": "Elias"
	},
}

var _dialog_instance: DialogScreen = null
var is_open = false
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("idle")

func _on_body_entered(body):
	if body.is_in_group("player") and not is_open:
		await show_dialog_before_opening()

func _show_dialog(dialog_data2: Dictionary):
	if is_instance_valid(_dialog_instance):
		_dialog_instance.queue_free()
	_dialog_instance = DialogScreen.instantiate()
	_dialog_instance.data = dialog_data2
	hud.add_child(_dialog_instance)
	await _dialog_instance.tree_exited  # Espera o diálogo ser fechado (quando for removido da árvore)

func show_dialog_before_opening():
	is_open = true
	await _show_dialog(dialog_data2)  # Mostra e espera o diálogo terminar
	chest_open.play()
	sprite.play("open")
	await sprite.animation_finished  # Espera a animação terminar
	spawn_item()

func spawn_item():
	if item_scene:
		var item_instance = item_scene.instantiate()
		if item_instance is Area2D:
			item_instance.global_position = global_position + Vector2(0, -40)
			get_parent().get_parent().add_child(item_instance)
			item_instance.add_to_group("disfarce")
			item_instance.connect("camisa_coletada", Callable(get_parent().get_parent(), "_on_disfarce_coletado"))
		else:
			print("Erro: item_scene não é um Area2D!")
