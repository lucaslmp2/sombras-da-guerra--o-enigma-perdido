extends Node2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_sigin_bryan: Area2D = $"Instruções"

const lines : Array[String] = [
	"Olá, aventureiro!",
	"Seja Bem Vindo!!!",
	"É muito bom vê-lo por aqui...",
	"A nossa jornada começa agora...",
	"Espero que esteja preparado...",
	"Encontre o pergaminnho com pistas do seu primeiro desafio!!!",
	"Aqui vai uma dica!!!",
	"Cuidado com a aguá você pode se afogar!!! Cuidado com as plataformas elas balançam um pouco você pode cair!!!",
	"Você pode coletar itens em baús espalhados pelo mapa...",
	"Encontre o pergaminnho com pistas do seu primeiro desafio!!!",
	"Continue explorando o jogo...",
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
