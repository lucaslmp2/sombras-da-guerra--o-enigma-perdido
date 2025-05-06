extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var trem_andando: AudioStreamPlayer2D = $trem_andando
#@onready var collision_shape_2d_4: CollisionShape2D = $CharacterBody2D/CollisionShape2D4
@onready var locomotiva: Area2D = $"."
@onready var smoke: AnimatedSprite2D = $smoke
@onready var smoke2: AnimatedSprite2D = $smoke2

var andando = false
var velocidade = 300 # Pixels por segundo (ajuste conforme necessário)
var distancia_percorrida = 0
var distancia_total = 8000
@onready var smoke_2: AnimatedSprite2D = $smoke2

func _ready():
	pass
func iniciar_movimento():
	smoke.play("smoke_2")
	smoke2.play("smoke")
	locomotiva.z_index = 1
	animated_sprite_2d.play("run")
	andando = true
	trem_andando.play()
	distancia_percorrida = 0
func parar_movimento():
	locomotiva.z_index = 0
	animated_sprite_2d.play("idle")
	andando = false
	trem_andando.stop()
	distancia_percorrida = distancia_total
func _physics_process(delta):
	if andando:
		var movimento = velocidade * delta
		position.x += movimento
		distancia_percorrida += movimento

		if distancia_percorrida >= distancia_total:
			andando = false
			trem_andando.stop()
			animated_sprite_2d.play("idle")
			locomotiva.z_index = 0


func _on_area_de_embarque_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		iniciar_movimento()
	


func _on_area_de_embarque_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		parar_movimento()
