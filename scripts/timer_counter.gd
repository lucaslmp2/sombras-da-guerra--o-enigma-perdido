extends NinePatchRect

@onready var timer: Label = $timer
@onready var counter_timer: Timer = $counter_timer
var minutes = 0
var seconds = 0
@export_range(0, 5) var default_minutes := 1
@export_range(0, 59) var default_seconds := 0
signal timer_is_up

func _process(delta: float) -> void:
	if minutes == 0 and seconds == 0:
		emit_signal("timer_is_up")

func _ready() -> void:
	timer.text = str("%02d" % default_minutes) + ":" + str("%02d" % default_seconds)
	reset_clock_timer()
	timer_is_up.connect(_on_timer_is_up) # Conecta o sinal à função de reset

func _on_counter_timer_timeout() -> void:
	if seconds == 0:
		if minutes > 0:
			minutes -= 1
			seconds = 59 # Correção: quando os minutos diminuem, os segundos vão para 59
		elif minutes == 0:
			seconds = 0 # Garante que os segundos fiquem em 0 quando o tempo acaba
	else:
		seconds -= 1
	timer.text = str("%02d" % minutes) + ":" + str("%02d" % seconds)

func reset_clock_timer():
	minutes = default_minutes
	seconds = default_seconds
	timer.text = str("%02d" % minutes) + ":" + str("%02d" % seconds)
	counter_timer.start() # Reinicia o timer quando o clock é resetado

func _on_timer_is_up():
	print("Tempo acabou! Resetando o jogo...")
	# Adicione aqui a lógica para resetar o seu jogo
	# Isso pode incluir:
	# - Recarregar a cena atual:
	get_tree().reload_current_scene()
	# - Carregar uma cena de game over ou de reset:
	# get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	# - Resetar variáveis de pontuação, vida, posição do jogador, etc.:
	# Globals.score = 0
	# get_node("Path/To/Player").global_position = Vector2(x, y)
	reset_clock_timer() # Reinicia o timer após o reset do jogo
