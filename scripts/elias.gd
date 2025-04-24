extends CharacterBody2D

@onready var animation := $AnimatedSprite2D
const SPEED = 100.0
var prologo_ativo := true
@onready var audio_passos: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _physics_process(delta):
	if prologo_ativo:
		velocity.x = SPEED
		move_and_slide()

		# Animação + som de passos
		if not animation.is_playing() or animation.animation != "walk":
			animation.play("walk")
		if not audio_passos.playing:
			audio_passos.play()

		animation.scale.x = 1

		if global_position.x >= 350:
			velocity = Vector2.ZERO
			move_and_slide()
			prologo_ativo = false
			animation.play("idle2")
			if audio_passos.playing:
				audio_passos.stop()
	else:
		var input_x = Input.get_axis("ui_left", "ui_right")
		velocity.x = input_x * SPEED

		if input_x != 0:
			animation.scale.x = input_x
			animation.play("walk")
			if not audio_passos.playing:
				audio_passos.play()
		else:
			animation.play("idle2")
			if audio_passos.playing:
				audio_passos.stop()

		move_and_slide()
