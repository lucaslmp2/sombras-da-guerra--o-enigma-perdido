extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Item coletado!")  # Aqui você pode adicionar ao inventário
		queue_free()  # Remove o item da cena
