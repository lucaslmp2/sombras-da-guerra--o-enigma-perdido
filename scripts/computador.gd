extends Area2D

@onready var sprite: Sprite2D = $"CapturaDeTela2025-03-24144422"	
@onready var timer: Timer = $Timer
@onready var transi__o: Area2D = $"Transição"

# Detecta quando o jogador entra na área de interação
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # Se for o jogador
		sprite.visible = true
		if Input.is_action_just_pressed("advance_message"):
			print("apertou")
			transi__o.visible = true

func _on_body_exited(body: Node2D) -> void:
	sprite.visible = false
