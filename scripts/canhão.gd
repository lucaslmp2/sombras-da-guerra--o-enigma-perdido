extends Area2D

signal desligar_canhao # Sinal para ser emitido pelo computador

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_box_canhao: CollisionShape2D = $hurt_box_canhao
@onready var fogo: AnimatedSprite2D = $Fogo
@onready var fogo_2: AnimatedSprite2D = $Fogo2
@onready var som_de_fogo: AudioStreamPlayer2D = $som_de_fogo

var ligado: bool = false

func _ready():
	ligar()

func ligar():
	ligado = true
	animated_sprite_2d.play("ligado")
	fogo.visible = true
	fogo_2.visible = true
	hurt_box_canhao.disabled = false
	som_de_fogo.play()

func desligar():
	ligado = false
	animated_sprite_2d.play("desligado")
	fogo.visible = false
	fogo_2.visible = false
	hurt_box_canhao.disabled = true
	som_de_fogo.stop()

func _on_body_entered(body):
	if ligado and body.has_method("take_damage"):
		body.take_damage(20)

func _on_body_exited(body):
	# Opcional: Adicionar alguma lógica ao sair da área, se necessário
	pass

func _on_Canhao_desligar_canhao():
	desligar()
