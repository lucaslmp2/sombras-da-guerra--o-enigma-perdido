extends Area2D
@onready var hud: CanvasLayer = $"../../HUD"
const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")

var dialog_data: Dictionary={
	0:{
		"faceset":"res://Assets/Prontos/face_asset_mulher_sobrivivente.png",
		"dialog":"Socorro!!! Ajude-nos, Por favor!",
		"title":"Sobrevivente"
	},	
	1:{
		"faceset":"res://Assets/Prontos/face_asset_mulher_sobrivivente.png",
		"dialog":"Encontre a chave com o Rider e nos liberte!",
		"title":"Sobrevivente"
	},
}

@export_category("Objects")
var _dialog_instance: DialogScreen
var _dialog_shown: bool = false # Add this new variable

func _show_dialog(dialog_data: Dictionary):
	if is_instance_valid(_dialog_instance):
		_dialog_instance.queue_free()
	_dialog_instance = DialogScreen.instantiate()
	_dialog_instance.data = dialog_data
	hud.add_child(_dialog_instance)
	_on_dialog_exited()

func _on_dialog_exited():
	_dialog_instance = null
	_dialog_shown = true # Set this to true when the dialogue finishes

func _on_body_entered(body: Node2D) -> void:
	if not _dialog_shown: # Only show if it hasn't been shown yet
		_show_dialog(dialog_data)
