extends Area2D
@onready var anim: AnimatedSprite2D = $Anim
@onready var pickup: AudioStreamPlayer2D = $pickup
@onready var collision: CollisionShape2D = $collision

var hart := 1
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("enable_throwing") and body is CharacterBody2D:
		collision.disabled = false
		pickup.play()
		anim.play("collect")
		await get_tree().create_timer(0.2).timeout
		Globals.life += hart
		queue_free()
	else:
		print("Corpo que entrou não é o player ou não tem 'enable_throwing'")
