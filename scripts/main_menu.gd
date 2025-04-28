extends Control

@export var game_scene: String = "res://Level/fase_1.tscn"  # Define a cena do jogo
@export var menu_scene: String = "res://Level/main_menu.tscn"  # Define a cena do menu principal
@onready var click: AudioStreamPlayer2D = $click
@onready var intro: AudioStreamPlayer2D = $Intro

func _ready() -> void:
	$VBoxContainer/ButtonJogar.pressed.connect(_on_jogar_pressed)
	$VBoxContainer/ButtonOpcoes.pressed.connect(_on_opcoes_pressed)
	$VBoxContainer/ButtonSair.pressed.connect(_on_sair_pressed)
	intro.play()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)  # Volta para o menu principal

func _on_jogar_pressed() -> void:
	click.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(game_scene)  # Vai para o jogo

func _on_opcoes_pressed() -> void:
	click.play()
	await get_tree().create_timer(1.0).timeout
	print("Opções ainda não implementadas!")  # Podemos adicionar um menu depois

func _on_sair_pressed() -> void:
	click.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()  # Fecha o jogo
