extends Control

@onready var input_field = $LineEdit
@onready var message_label = $Label_senha_incorreta
@onready var message_label_acesso = $Label_senha_correta
@onready var label_texto: Label = $Label_texto
@onready var audio_tecla: AudioStreamPlayer2D = $digitação
@onready var mouse_click: AudioStreamPlayer2D = $Mouse_click
@onready var enigma_resolvido: AudioStreamPlayer2D = $"../../escritorio/decoração_escritorio/NinePatchRect4/computador/enigma_resolvido"

signal tela_fechada
signal resposta_correta

var correct_answer = "Polonia"
var correct_answer2 = "polonia"

func _ready() -> void:
	label_texto.text = "Um rugido ecoou na madrugada cinzenta. Sem honra, atravessaram as fronteiras adormecidas, e um povo foi lançado nas sombras sem aviso. Ali, sob o céu frio de setembro, começou a tempestade que tomaria o mundo. Qual foi o primeiro a cair sob o peso dessa fúria?"
	input_field.connect("gui_input", Callable(self, "_on_input_gui"))
func _on_Button_pressed():
	mouse_click.play()
	if input_field.text == correct_answer or input_field.text == correct_answer2:
		message_label_acesso.text = "Acesso concedido!"
		message_label.text = ""  # limpa erro
		enigma_resolvido.play()
		await get_tree().create_timer(11.0).timeout
		emit_signal("resposta_correta")
	else:
		message_label.text = "Desculpe. Tente novamente."
		message_label_acesso.text = ""  # limpa sucesso

func _on_button_pressed_sair():
	mouse_click.play()
	emit_signal("tela_fechada")
	
func _on_input_gui(event: InputEvent) -> void:
	# só reage a teclas pressionadas (não repeats)  
	if event is InputEventKey and event.pressed and not event.echo:
		# opcional: variar levemente o pitch para não ficar repetitivo
		audio_tecla.pitch_scale = randf_range(0.9, 1.1)
		audio_tecla.play()
