extends Control
@onready var interface: Control = $"."
func _ready() -> void:
	interface.time_is_up.connect(reload_game)
	
