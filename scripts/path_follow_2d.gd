extends PathFollow2D

@export var velocidade: float = 50.0
var pode_andar: bool = false

func _physics_process(delta: float) -> void:
	if pode_andar:
		progress += velocidade * delta

func iniciar_movimento():
	pode_andar = true

func parar_movimento():
	pode_andar = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	iniciar_movimento()


func _on_area_2d_body_exited(body: Node2D) -> void:
	parar_movimento()
