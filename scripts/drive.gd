extends Area2D

signal pick_up_chave
@onready var audio_pickup: AudioStreamPlayer2D = $pick_up
var _dialog_instance: DialogScreen
var hud: CanvasLayer = null
const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
var dialog_data: Dictionary = {
	0: {
		"faceset": "res://Assets/Prontos/face_aset_elias_sorrindo1.png",
		"dialog": "Nossa a Chave.",
		"title": "Elias"
	},
	1:{
		"faceset": "res://Assets/Prontos/face_aset_elias_sorrindo1.png",
		"dialog": "Foi mais facíl do que imaginei.",
		"title": "Elias"
	},
}

func _ready():
	var scene_root = get_tree().current_scene
	hud = scene_root.find_child("HUD", true, false)
	
func _show_dialog(dialog_data: Dictionary):
	if not hud:
		push_error("HUD não encontrado!")
		return
	if is_instance_valid(_dialog_instance):
		_dialog_instance.queue_free()
	_dialog_instance = DialogScreen.instantiate()
	_dialog_instance.data = dialog_data
	hud.add_child(_dialog_instance)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("Item coletado!")
		_show_dialog(dialog_data)
		audio_pickup.play()
		emit_signal("pick_up_chave")
		await get_tree().create_timer(1.0).timeout
		queue_free()
