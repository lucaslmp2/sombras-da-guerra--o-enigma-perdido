extends Control

@export var game_scene_fase1: String = "res://Level/fase_3.tscn"  # Define a cena do jogo
@export var game_scene_fase2: String = "res://Level/fase_3_1.tscn"  # Define a cena do jogo
@export var game_scene_fase3: String = "res://Level/fase_3_2.tscn"  # Define a cena do jogo
@export var game_scene_fase4: String = "res://Level/fase_4_0.tscn"  # Define a cena do jogo
@export var menu_scene: String = "res://Level/main_menu.tscn"  # Define a cena do menu principal
@onready var click: AudioStreamPlayer2D = $click
@onready var intro: AudioStreamPlayer2D = $Intro

func _ready() -> void:
	$VBoxContainer/Fase_1.pressed.connect(_on_fase1_pressed)
	$VBoxContainer/Fase_2.pressed.connect(_on_fase2_pressed)
	$VBoxContainer/Faze_3.pressed.connect(_on_fase3_pressed)
	$VBoxContainer/Faze_4.pressed.connect(_on_fase4_pressed)
	$VBoxContainer/Voltar.pressed.connect(_on_voltar_pressed)
	intro.play()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)  # Volta para o menu principal

func _on_fase1_pressed() -> void:
	click.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(game_scene_fase1)  # Vai para o jogo

func _on_fase2_pressed() -> void:
	click.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(game_scene_fase2)  # Vai para o jogo
func _on_fase3_pressed() -> void:
	click.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(game_scene_fase3)  # Vai para o jogo
func _on_fase4_pressed() -> void:
	click.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(game_scene_fase4)  # Vai para o jogo

func _on_voltar_pressed() -> void:
	click.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(menu_scene)
	
