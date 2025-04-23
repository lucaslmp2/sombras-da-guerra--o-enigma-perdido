extends Area2D

@onready var path_follow_2d: PathFollow2D = get_parent()

func _on_body_entered(body):
	if body.is_in_group("player"):
		if path_follow_2d.has_method("iniciar_movimento"):
			path_follow_2d.iniciar_movimento()
		else:
			printerr("Erro: PathFollow2D não possui a função 'iniciar_movimento'.")

func _on_body_exited(body):
	if body.is_in_group("player"):
		if path_follow_2d.has_method("parar_movimento"):
			path_follow_2d.parar_movimento()
		else:
			printerr("Erro: PathFollow2D não possui a função 'parar_movimento'.")
