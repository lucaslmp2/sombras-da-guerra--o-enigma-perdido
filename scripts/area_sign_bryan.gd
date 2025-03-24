extends Node2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_sigin_bryan: Area2D = $area_sigin_bryan

const lines : Array[String] = [
	"Olá, aventureiro!",
	"Meu nome é Bryan",
	"É muito bom vê-lo por aqui",
	"Vou ajudar você",
	"Espero que esteja preparado...",
	"Sua jornada está apenas...",
	"...COMEÇANDO!",
]
func _unhandled_input(event):
	if area_sigin_bryan.get_overlapping_bodies().size() > 0:
		animated_sprite_2d.show()
		if event.is_action_pressed("interact") && !DialogManager.is_message_active:
			animated_sprite_2d.hide()
			DialogManager.start_message(global_position, lines)
	else:
		animated_sprite_2d.hide()
		if DialogManager.dialog_box != null:
			DialogManager.dialog_box.queue_free()
			DialogManager.is_message_active = false
