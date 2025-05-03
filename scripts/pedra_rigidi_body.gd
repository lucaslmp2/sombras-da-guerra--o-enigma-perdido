extends RigidBody2D

@onready var rolando_no_chão: AudioStreamPlayer2D = $rolando_no_chão
var is_rolling := false # Variável para controlar se a pedra está rolando
@export var damage := 1 # Dano que a pedra causa ao contato

func _ready():
	rolando_no_chão.play()
	is_rolling = true

func _physics_process(delta):
	# Se a pedra estiver se movendo e o som não estiver tocando, comece a tocar
	if linear_velocity.length() > 10 && !rolando_no_chão.playing && is_rolling:
		rolando_no_chão.play()
	# Se a pedra estiver parada ou quase parada, pare o som
	elif linear_velocity.length() <= 10:
		rolando_no_chão.stop()
		is_rolling = false

func throw_stone(direction: Vector2):
	var speed = 150 # Ajuste a velocidade do lançamento conforme necessário
	linear_velocity = direction * speed
	apply_impulse(direction * speed)

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage)
	if !is_rolling:
		rolando_no_chão.play()
		is_rolling = true
