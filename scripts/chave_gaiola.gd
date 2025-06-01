extends Area2D
# Remova 'signal pick_up_chave' daqui, pois o sinal será emitido pelo SignalManager

@onready var player: CharacterBody2D = null
var hud: CanvasLayer = null
@onready var pick_up: AudioStreamPlayer2D = $pick_up
var _dialog_instance: DialogScreen
const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")

var dialog_data: Dictionary = {
	0: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Nossa a Chave.",
		"title": "Elias"
	},
	1:{
		"faceset": "res://Assets/Prontos/face_asset_mulher_sobrivivente.png",
		"dialog": "Oh Deus, obrigado!!!",
		"title": "sobrevivente"
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
	await _dialog_instance.tree_exited

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		print("Item coletado!")
		await _show_dialog(dialog_data)
		pick_up.play()
		
		# <<< AQUI ESTÁ A MUDANÇA PRINCIPAL >>>
		# Emite o sinal através do SignalManager
		SignalManager.chave_coletada.emit() 
		print("Sinal 'chave_coletada' emitido via SignalManager!")
		
		await get_tree().create_timer(1.0).timeout
		queue_free()
