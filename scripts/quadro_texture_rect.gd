extends Control

@onready var hud: CanvasLayer = $"../../../../.."

const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
var dialog_data: Dictionary = {
	0: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Um mapa da ocupação nazista",
		"title": "Elias",
	},
	1: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Não acredito que estou neste tempo!",
		"title": "Elias",
	},
	2:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Onde é esta estrada?",
		"title":"Elias"
	},	
	3:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Não me recordo de nenhum lugar assim.",
		"title":"Elias"
	},
	4:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Berlim parece ser o coração de toda a operação",
		"title":"Elias"
	},	
	5:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Deve ser a casa do Adolf",
		"title":"Elias"
	},
	6:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Meu deus quanta crueldade!!!",
		"title":"Elias"
	},	
	7:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Trabaladores sendo explorados de forma desumana",
		"title":"Elias"
	},
	8: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Esse lugar!!!",
		"title": "Elias",
	},
	9: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Que sensacao horrível!!!",
		"title": "Elias",
	},
	10:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Não faz sentido uma estação abandonada, por quê?",
		"title":"Elias"
	},	
	11:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Estes símbolos nas paredes devem significar algo!",
		"title":"Elias"
	},
}
var _dialog_instance: DialogScreen
var _dialog_exibido: bool = false

func _on_mouse_entered() -> void:
		if !_dialog_exibido:
			_dialog_instance = DialogScreen.instantiate()
			_dialog_instance.data = dialog_data
			hud.add_child(_dialog_instance)
			_dialog_instance.connect("tree_exited", Callable(self, "_on_dialog_exited"))
			_dialog_exibido = true
