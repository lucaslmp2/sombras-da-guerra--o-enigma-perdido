extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $Anim
@onready var area_2d: Area2D = $Area2D

const lines : Array[String] = [
	"Olá, aventureiro!",
	"Seja Bem Vindo!!!",
	"É muito bom vê-lo por aqui...",
	"A nossa jornada começa agora...",
	"Espero que esteja preparado...",
	"Encontre o pergaminnho com pistas do seu primeiro desafio!!!",
	"Aqui vai uma dica!!!",
	"Cuidado com a aguá você pode se afogar!!!",
	"Avance para frente para explorar o jogo...",
]

func _unhandled_input(event: InputEvent) -> void:
	if area_2d.get_overlapping_bodies().size() > 0:
		animated_sprite_2d.show()
		if event.is_action_pressed("interact") && !DialogManager.is_message_active:
			animated_sprite_2d.hide()
			DialogManager.start_message(global_position, lines)
		else:
			animated_sprite_2d.hide()
			if DialogManager.dialog_box != null:
				DialogManager.dialog_box.queue_free()
				DialogManager.is_message_active = false
