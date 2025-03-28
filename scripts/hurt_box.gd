extends Area2D

@export var player_group: String = "player"  # Define o grupo do player
@export var enemy_group: String = "enemy"  # Define o grupo do player
@export var jump_force: float = -400.0  # Ajuste a força do pulo
@export var death_animation_time: float = 0.4 # Tempo da animação de morte

var is_dying: bool = false  # Evita que o código seja executado mais de uma vez

func _on_body_entered(body):
	if is_dying:  # Se o player já está morrendo, não faz nada
		return
	if body.is_in_group(player_group):
		is_dying = true  # Marca que o player está morrendo para evitar loops
		if body.has_method("pulo"):
			body.jump()  # Faz o player pular
		else:
			body.velocity.y = jump_force  # Aplica impulso manualmente
			
		await get_tree().create_timer(death_animation_time).timeout  # Espera a animação terminar
		body.queue_free()  # Remove o player da cena
	if is_dying:  # Se o player já está morrendo, não faz nada
		return
	if body.is_in_group(enemy_group):
		is_dying = true  # Marca que o player está morrendo para evitar loops
		if body.has_method("pulo"):
			body.jump()  # Faz o player pular
		else:
			body.velocity.y = jump_force  # Aplica impulso manualmente
			
		await get_tree().create_timer(death_animation_time).timeout  # Espera a animação terminar
		body.queue_free()  # Remove o player da cena
