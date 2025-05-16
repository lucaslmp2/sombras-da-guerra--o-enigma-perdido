extends Area2D
@onready var quadro_enigma_expandido: Control = $"../../HUD/QuadroEnigmaExpandido"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		quadro_enigma_expandido.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		quadro_enigma_expandido.visible = false
