extends Area2D
@onready var coletado: AudioStreamPlayer2D = $coletado

var pedra := 1
var coletando := false # Adicionamos uma variável de controle

func _on_body_entered(body: Node2D) -> void:
	if coletando: # Verifica se já estamos processando uma colisão
		return

	# Verifica se o corpo que colidiu pertence ao grupo "player"
	if body.is_in_group("player"):
		coletando = true
		coletado.play()
		await get_tree().create_timer(0.3).timeout

		if is_instance_valid(body) and body.has_method("enable_throwing"):
			$CollisionShape2D.queue_free()
			Globals.pedra += pedra
			if Globals.pedra > 0:
				body.enable_throwing()
			queue_free()
		else:
			# Se não for o player, reseta a flag de coleta para que outros possam interagir
			coletando = false
