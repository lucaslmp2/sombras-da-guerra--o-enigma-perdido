extends Node

@onready var dialog_box_scene = preload("res://Prefabs/dialog_box.tscn")
var message_lines : Array[String] = []
var current_line = 0
var dialog_box
var dialog_box_position := Vector2.ZERO
var is_message_active := false
var can_advance_message := false

func start_message(position: Vector2, lines: Array[String]):
	print("Iniciando diálogo com as mensagens:", lines)
	if lines.is_empty():
		print("Erro: Nenhuma mensagem recebida!")
		return
	if dialog_box != null:
		dialog_box.queue_free()
		await get_tree().idle_frame  # Aguarda 1 frame para garantir remoção
	message_lines = lines
	dialog_box_position = position
	current_line = 0
	show_text()
	is_message_active = true

func show_text():
	print("Exibindo o texto:", message_lines[current_line])  # Debug
	if message_lines.is_empty():
		print("Erro: Tentativa de exibir texto, mas `message_lines` está vazio!")
		return
	dialog_box = dialog_box_scene.instantiate()
	dialog_box.text_display_finished.connect(_on_all_text_displayed)
	get_tree().root.add_child(dialog_box)

	dialog_box.global_position = dialog_box_position
	dialog_box.display_text(message_lines[current_line])
	can_advance_message = false

func _on_all_text_displayed():
	can_advance_message = true  # Permite avançar para a próxima linha

func _unhandled_input(event):
	if event.is_action_pressed("advance_message") and is_message_active and can_advance_message:
		print("Avançando para a próxima linha:", current_line)  # Debug
		if dialog_box != null:
			dialog_box.queue_free()
			dialog_box = null  # Garante que o diálogo anterior foi removido
		
		current_line += 1  # Avança para a próxima linha

		if current_line >= message_lines.size():
			is_message_active = false  # Fim do diálogo
			current_line = 0  # Reinicia o contador
			return
		
		show_text()  # Exibe a próxima linha do diálogo
