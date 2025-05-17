extends TextureRect

const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
var scale_factor = 4.0 # Fator de escala para o aumento
var original_scale = Vector2(1, 1) # Escala original da imagem
@onready var hud: CanvasLayer = $"../../../../../.."

var dialog_data: Dictionary={
	0:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Onde é esta estrada?",
		"title":"Elias"
	},	
	1:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Não me recordo de nenhum lugar assim.",
		"title":"Elias"
	},
}
var _dialog_instance: DialogScreen
var _dialog_exibido: bool = false # Variável para rastrear se o diálogo foi exibido

func _ready() -> void:
	# Salva a escala original
	original_scale = scale

func _on_dialog_exited():
	_dialog_instance = null # Limpa a referência quando o diálogo é removido da cena
	
func _on_mouse_entered() -> void:
	scale = original_scale * scale_factor
	z_index += 1
	if !_dialog_exibido: # Verifica se o diálogo ainda não foi exibido
		_dialog_instance = DialogScreen.instantiate()
		_dialog_instance.data = dialog_data
		hud.add_child(_dialog_instance)
		_dialog_instance.connect("tree_exited", Callable(self, "_on_dialog_exited"))
		_dialog_exibido = true # Marca o diálogo como exibido

func _on_mouse_exited() -> void:
	_on_dialog_exited()
	# Restaura a escala original da imagem
	scale = original_scale
	z_index -= 1
