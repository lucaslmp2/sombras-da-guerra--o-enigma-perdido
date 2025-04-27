extends Area2D

signal pick_up_pendrive

@onready var audio_pickup: AudioStreamPlayer2D = $pick_up

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("Item coletado!")  # Agora vai aparecer no console
		audio_pickup.play()      # Reproduz o som
		emit_signal("pick_up_pendrive")  # Emite o sinal
		await get_tree().create_timer(1.0).timeout
		queue_free()  # Remove o item da cena
