extends Node2D
@onready var animation_player: AnimationPlayer = $HUD/AnimationPlayer
@onready var player: CharacterBody2D = $characters/Player
@export var menu_scene: String = "res://Level/main_menu.tscn"# Define a cena do menu principal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.player_died.connect(reload_game)
	animation_player.play("fade_out")
	await animation_player.animation_finished
	animation_player.play("nigth")
	
func reload_game():
	Globals.life = 3 # **RESETA Globals.life AQUI**
	Globals.bulets = 10
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)# Volta para o menu principal
