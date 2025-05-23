extends Area2D

@export var proxima_cena : String = "res://Level/fase1.tscn"

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		call_deferred("change_scene")  # Adia a mudança de cena

func change_scene() -> void:
	get_tree().change_scene_to_file(proxima_cena)
