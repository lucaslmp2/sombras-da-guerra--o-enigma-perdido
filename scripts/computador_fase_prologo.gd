extends Area2D

@onready var colisao_pc: CollisionShape2D = $CollisionShape2D
@onready var audio_alerta: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Deixa o alerta invisível inicialmente
	anim.visible = false

func _on_body_entered(body):
	if body.name == "Elias":
		anim.visible = true
		anim.play("alerta_computador") # se tiver uma animação
		audio_alerta.play()
