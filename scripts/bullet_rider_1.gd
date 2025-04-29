extends Area2D

@export var damage: int = 1
var velocity: Vector2
@onready var ricochet: AudioStreamPlayer2D = $ricochet
func _ready() -> void:
	ricochet.play()
func _physics_process(delta):
	position += velocity * delta
	# Adicione lógica para a bala ser destruída após um tempo ou sair da tela

func _on_body_entered(body):
	print("BULLET: _on_body_entered() com o corpo:", body.name)
	if body.has_method("take_damage"):
		print("BULLET: Chamando take_damage() no corpo:", body.name, "com dano:", damage)
		body.take_damage(damage)
		print("BULLET: Chamada de take_damage() concluída. Queue freeing self.")
		queue_free() # Destrói a bala após causar dano
	else:
		print("BULLET: O corpo", body.name, "não tem o método take_damage(). Queue freeing self.")
		queue_free()
