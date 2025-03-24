extends Node2D
@onready var anim: AnimatedSprite2D = $Anim
@onready var area_instrucao_bau: Area2D = $area_instrucao_bau
const lines2 : Array[String] = [
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
func _unhandled_input(event):
	if area_instrucao_bau.get_overlapping_bodies().size() > 0:
		anim.show()
		if event.is_action_pressed("interact") && !DialogManager.is_message_active:
			anim.hide()
			DialogManager.start_message(global_position, lines2)
	else:
		anim.hide()
		if DialogManager.dialog_box != null:
			DialogManager.dialog_box.queue_free()
			DialogManager.is_message_active = false
