extends Area2D

@export var item_scene: PackedScene = preload("res://Prefabs/item.tscn")
@onready var open_bau: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite = $AnimatedSprite2D
@onready var hud: CanvasLayer = get_node("/root/Fase_1/HUD")

const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")

var dialog_data: Dictionary = {
	0: {
		"faceset": "res://Assets/Prontos/face aset elias2 sorrindo.png",
		"dialog": "Nossa um baú. Que estranho.",
		"title": "Elias"
	},
	1: {
		"faceset": "res://Assets/Prontos/face aset elias2 sorrindo.png",
		"dialog": "O que será que tem dentro?",
		"title": "Elias"
	},
}

var _dialog_instance: DialogScreen = null
var is_open = false
var evento_realizado := false

func _ready():
	sprite.play("closed")

func _on_body_entered(body):
	if body.is_in_group("player") and not is_open:
		await show_dialog_before_opening()

func _show_dialog(dialog_data: Dictionary):
	if is_instance_valid(_dialog_instance):
		_dialog_instance.queue_free()
	_dialog_instance = DialogScreen.instantiate()
	_dialog_instance.data = dialog_data
	hud.add_child(_dialog_instance)
	await _dialog_instance.tree_exited  # Espera o diálogo ser fechado (quando for removido da árvore)

func show_dialog_before_opening():
	is_open = true
	await _show_dialog(dialog_data)  # Mostra e espera o diálogo terminar
	open_bau.play()
	sprite.play("open")
	await sprite.animation_finished  # Espera a animação terminar
	spawn_item()

func spawn_item():
	if item_scene:
		var item_instance = item_scene.instantiate()
		if item_instance is Area2D:
			item_instance.global_position = global_position + Vector2(0, -40)
			get_parent().get_parent().add_child(item_instance)
			item_instance.add_to_group("pendrives")
			item_instance.connect("pick_up_pendrive", Callable(get_parent().get_parent(), "_on_pendrive_coletado"))
			Globals.pen_drive = item_scene
			print(Globals.pen_drive)
		else:
			print("Erro: item_scene não é um Area2D!")
