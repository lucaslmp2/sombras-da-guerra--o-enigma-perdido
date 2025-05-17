extends TextureRect

const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
var scale_factor = 4.0
var original_scale = Vector2(1, 1)
@onready var hud: CanvasLayer = $"../../../../../.."

var dialog_data: Dictionary = {
	0: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Esse lugar!!!",
		"title": "Elias",
	},
	1: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Que sensacao horrível!!!",
		"title": "Elias",
	},
}
var _dialog_instance: DialogScreen
var _dialog_exibido: bool = false
var _pode_exibir_dialogo: bool = false # Variável de controle

func _ready() -> void:
	original_scale = scale
	# Conecta ao sinal do outro TextureRect
	var mapa_texture_rect = get_node_or_null("HUD/QuadroEnigmaExpandido/PanelContainer/MarginContainer/TextureRect2/TextureRect") # Corrigido
	if mapa_texture_rect:
		mapa_texture_rect.connect("dialogo_mapa_acabou", Callable(self, "_liberar_dialogo"))

func _on_dialog_exited():
	_dialog_instance = null

func _on_mouse_entered() -> void:
	scale = original_scale * scale_factor
	z_index += 1
	if !_dialog_exibido && _pode_exibir_dialogo: # Verifica a variável de controle
		_dialog_instance = DialogScreen.instantiate()
		_dialog_instance.data = dialog_data
		hud.add_child(_dialog_instance)
		_dialog_instance.connect("tree_exited", Callable(self, "_on_dialog_exited"))
		_dialog_exibido = true

func _on_mouse_exited() -> void:
	_on_dialog_exited()
	scale = original_scale
	z_index -= 1
	_pode_exibir_dialogo = true

func _liberar_dialogo() -> void:
	_pode_exibir_dialogo = true # Libera a exibição do diálogo
	_dialog_exibido = false # Permite que o diálogo seja exibido novamente na próxima vez
