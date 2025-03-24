extends Area2D

@onready var sprite: Sprite2D = $"CapturaDeTela2025-03-24144422"	
@onready var timer: Timer = $Timer

# Detecta quando o jogador entra na área de interação
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # Se for o jogador
		get_parent()._on_objeto_interagido("computador")  # Notifica a fase
		sprite.visible = true


# Mostra a imagem e inicia o timer quando o jogador interage
func _on_objeto_interagido(objeto: String):
	if objeto == "computador":
		sprite.visible = true
		timer.start(5)  # A imagem ficará visível por 5 segundos

# Esconde a imagem quando o timer acaba
func _on_Timer_timeout():
	sprite.visible = false


func _on_body_exited(body: Node2D) -> void:
	sprite.visible = false
