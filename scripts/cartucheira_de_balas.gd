extends Area2D
@onready var texture: Sprite2D = $Sprite2D
@onready var pickup_bala: AudioStreamPlayer2D = $pickup_bala

var bullets := 5
func _on_body_entered(body: Node2D) -> void:
	pickup_bala.play()
	await get_tree().create_timer(0.3).timeout
	if body.has_method("take_damage") and body is CharacterBody2D: # Supondo que o player tem 'take_damage'
		Globals.bulets += bullets
		queue_free()
	else:
		print("Corpo que entrou não é o player.")
