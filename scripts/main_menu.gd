extends Control

@export var game_scene: String = "res://Level/fase1.tscn"  # Define a cena do jogo

func _ready() -> void:
	$VBoxContainer/ButtonJogar.pressed.connect(_on_jogar_pressed)
	$VBoxContainer/ButtonOpcoes.pressed.connect(_on_opcoes_pressed)
	$VBoxContainer/ButtonSair.pressed.connect(_on_sair_pressed)

func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file(game_scene)  # Vai para o jogo

func _on_opcoes_pressed() -> void:
	print("Opções ainda não implementadas!")  # Podemos adicionar um menu depois

func _on_sair_pressed() -> void:
	get_tree().quit()  # Fecha o jogo
