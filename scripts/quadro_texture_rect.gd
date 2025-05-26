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
		"dialog": "A estrada de sangue",
		"title": "Elias",
	},
	2:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Berlim",
		"title":"Elias"
	},	
	3:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Meu deus quanta crueldade!!!",
		"title":"Elias"
	},
	4:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Trabaladores sendo explorados de forma desuman",
		"title":"Elias"
	},	
	5:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Esse lugar!!!",
		"title":"Elias"
	},
	6:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Que sensacao horrível!!!",
		"title":"Elias"
	},
	7: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Não faz sentido uma estação abandonada, por quê?",
		"title": "Elias",
	},
	8: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Por que alguém iria querer investigar isso tudo",
		"title": "Elias",
	},
	9:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Não faz sentido tantas provas assim",
		"title":"Elias"
	},	
	10:{
		"faceset":"res://Assets/Prontos/face asset elias serio realista.png",
		"dialog":"Quem está por traz disso?",
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
