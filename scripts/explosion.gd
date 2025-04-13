extends Area2D

var damage : int = 3

func _ready():
	await get_tree().create_timer(0.1).timeout # Pequeno delay para garantir que a área esteja configurada
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage)
	var areas = get_overlapping_areas()
	for area in areas:
		if area.has_method("take_damage"):
			area.take_damage(damage)
	queue_free() # Destrói a área de explosão após aplicar o dano
