extends Node2D


@onready var player: CharacterBody2D = $character/Player
@export var menu_scene: String = "res://Level/main_menu.tscn"# Define a cena do menu principal
@onready var animation_player: AnimationPlayer = $HUD/AnimationPlayer
@onready var oil_bublle: Area2D = $oleo/Oil_bublle
@onready var oil_bublle_2: Area2D = $oleo/Oil_bublle2
@onready var ambiente_açao: AudioStreamPlayer2D = $ambiente_açao

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ambiente_açao.play()
	player.player_died.connect(reload_game)
	animation_player.play("fade_in")
	oil_bublle.player_died.connect(reload_game)
	oil_bublle_2.player_died.connect(reload_game)


func reload_game():
	Globals.life = 3 # Reseta a vida
	Globals.bulets = 10
	Globals.score = 0
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)# Volta para o menu principal   
