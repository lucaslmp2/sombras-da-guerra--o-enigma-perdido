extends Control # Ou Node2D, Node3D, o que for o pai do VideoStreamPlayer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var video_stream_player: VideoStreamPlayer = $"."

 # Substitua pelo caminho correto do seu nó
@export var menu_scene: String = "res://Level/main_menu.tscn"# Define a cena do menu principal
func _ready():
	audio_stream_player_2d.play()

func _on_video_finished():
	print("Vídeo terminou!")
	# Você pode querer esconder o player, mudar de cena, etc.
	# video_player.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)# Volta para o menu principal   
