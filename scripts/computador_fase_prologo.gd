# scripts/ComputerTrigger.gd
extends Area2D

@onready var colisao_pc: CollisionShape2D = $CollisionShape2D
@onready var audio_alerta: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var computer_cena: CanvasLayer = $"../../../../Computer_cena"

func _ready():
	anim.visible = false
	colisao_pc.disabled = true  # Desativa a colisão até que o pendrive seja coletado
	computer_cena.visible = false

func _on_body_entered(body: Node) -> void:
	if body.name == "Elias" and not colisao_pc.disabled:
		anim.visible = true
		anim.play("alerta_computador")
		audio_alerta.play()
		computer_cena.visible = true  # Mostra a tela do computador
