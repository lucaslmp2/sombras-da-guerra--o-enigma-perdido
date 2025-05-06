extends Area2D
@export var item_scene: PackedScene = preload("res://Prefabs/mp_40.tscn")
@onready var sprite: AnimatedSprite2D = $sprite
@onready var chest_open: AudioStreamPlayer2D = $chest_open
@onready var chest_close: AudioStreamPlayer2D = $chest_close

const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
@onready var hud: CanvasLayer = get_node("/root/Fase_3/HUD")
signal arma_coletada
var dialog_data: Dictionary = {
	0: {
		"faceset": "res://Assets/Prontos/face aset elias2 sorrindo.png",
		"dialog": "Heheheue, pelas minhas contas agora é a melhor parte!!!.",
		"title": "Elias"
	},
	1: {
		"faceset": "res://Assets/Prontos/face aset elias2 sorrindo.png",
		"dialog": "IIIIIUUUUUUUHHHH!!!",
		"title": "Elias"
	},
}

var _dialog_instance: DialogScreen = null
var is_open = false
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("idle")

func _on_body_entered(body):
	print("Corpo entrou no baú!")
	if body.is_in_group("player") and not is_open:
		print("É o player e o baú não está aberto.")
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
	print("Mostrando o diálogo...")
	await _show_dialog(dialog_data)
	print("Diálogo terminado.")
	chest_open.play()
	sprite.play("open")
	print("Animação de abrir iniciada.")
	await sprite.animation_finished
	print("Animação de abrir terminou.")
	spawn_item()

func spawn_item():
	if item_scene:
		var item_instance = item_scene.instantiate()
		if item_instance is Area2D:
			item_instance.global_position = global_position + Vector2(0, -40)
			get_parent().get_parent().add_child(item_instance)
			item_instance.add_to_group("disfarce")
			item_instance.connect("arma_coletada", Callable(get_parent().get_parent(), "_on_disfarce_coletado"))
		else:
			print("Erro: item_scene não é um Area2D!")
