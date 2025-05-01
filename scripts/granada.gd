extends Area2D
@onready var anim: AnimatedSprite2D = $Anim
@onready var pick_up_granada: AudioStreamPlayer2D = $pick_up_granada

var granada := 1
func _on_body_entered(body: Node2D) -> void:
	pick_up_granada.play()
	await get_tree().create_timer(0.3).timeout
	if body.has_method("enable_throwing") and body is CharacterBody2D:
		anim.play("collect")
		await $collision.call_deferred("queue_free")
		Globals.granada += granada
		if Globals.granada > 0:
			body.enable_throwing() # Reativa a habilidade de lançar
		await anim.animation_finished
		queue_free()
	else:
		print("Corpo que entrou não é o player ou não tem 'enable_throwing'")
