extends Control

@onready var texture_rect_1: TextureRect = $TextureRect
@onready var texture_rect_2: TextureRect = $TextureRect2
@onready var texture_rect_3: TextureRect = $TextureRect3
@onready var texture_rect_4: TextureRect = $TextureRect4
@onready var texture_rect_5: TextureRect = $TextureRect5
@onready var texture_rect_6: TextureRect = $TextureRect6

var dialogos_exibidos: int = 0
var pode_exibir_dialogo_1: bool = true
var pode_exibir_dialogo_2: bool = true
var pode_exibir_dialogo_3: bool = true
var pode_exibir_dialogo_4: bool = true
var pode_exibir_dialogo_5: bool = true
var pode_exibir_dialogo_6: bool = true

func _ready() -> void:
	# Define a ordem de exibição inicial
	texture_rect_1.z_index = 1
	texture_rect_2.z_index = 2
	texture_rect_3.z_index = 3
	texture_rect_4.z_index = 4
	texture_rect_5.z_index = 5
	texture_rect_6.z_index = 6

func _on_dialogo_exited() -> void:
	dialogos_exibidos += 1
	if dialogos_exibidos < 6: # Verifica se ainda há diálogos para exibir
		exibir_proximo_dialogo()

func exibir_proximo_dialogo() -> void:
	match dialogos_exibidos:
		1:
			texture_rect_2.emit_signal("mouse_entered")
		2:
			texture_rect_3.emit_signal("mouse_entered")
		3:
			texture_rect_4.emit_signal("mouse_entered")
		4:
			texture_rect_5.emit_signal("mouse_entered")
		5:
			texture_rect_6.emit_signal("mouse_entered")

func _on_algum_evento() -> void:
	# Altera a ordem de exibição dinamicamente
	texture_rect_1.z_index = 10
	texture_rect_2.z_index = 1
	# Agora texture_rect_1 está na frente de texture_rect_2
