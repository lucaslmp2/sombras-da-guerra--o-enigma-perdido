extends Node2D
@export var menu_scene: String = "res://Level/main_menu.tscn"  # Define a cena do menu principal
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)  # Volta para o menu principal
