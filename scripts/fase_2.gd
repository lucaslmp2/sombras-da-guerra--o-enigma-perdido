extends Node2D
@onready var player: CharacterBody2D = $character/Player
@onready var interface: Control = $HUD/Interface
@onready var raider_1: CharacterBody2D = $raider_1
@onready var agua: Node2D = $Agua/HurtBoxAgua
@onready var queda: Node2D = $Agua/Queda_livre
@onready var queda2: Node2D = $Agua/Queda_livre2


@export var menu_scene: String = "res://Level/main_menu.tscn"  # Define a cena do menu principal
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)  # Volta para o menu principal
func _ready() -> void:
	Globals.bulets = 10
	Globals.granada = 3
	Globals.life = 3
	Globals.score = 0
	player.player_died.connect(reload_game)
	agua.player_died.connect(reload_game)
	queda.player_died.connect(reload_game)
	queda2.player_died.connect(reload_game)

func reload_game():
	Globals.life = 3 # **RESETA Globals.life AQUI**
	await   get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
