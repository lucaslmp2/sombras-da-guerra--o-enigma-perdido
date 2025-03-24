extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var dialog_box: MarginContainer = $MarginContainer
@onready var label: Label = $MarginContainer/MarginContainer/Label

var dialog_active: bool = false
var current_dialog_index: int = 0

# Lista de falas do NPC
var DIALOG_TEXTS = [
	"Olá, aventureiro! Ultilize a tecla 'O' para avançar o dialogo",
	"Meu nome é Bryan",
	"É muito bom vê-lo por aqui",
	"Vou ajudar você",
	"Espero que esteja preparado...",
	"Sua jornada está apenas...",
	"...COMEÇANDO!",
	"Aqui vai algumas intruções para você:",
	"Para se movimentar no jogo ultilize:",
	"Setas para 'direita' e 'esquerda' do seu teclado para se mover",
	"'Espaço' para pular",
	"'I' para interagir com uma Quest = '!'",
	"Para voltar ao Menu Principal aperte 'ESC'",
]

func _ready() -> void:
	animated_sprite_2d.play("idle")
	dialog_box.visible = false  # Oculta a caixa de diálogo no início

func _process(_delta: float) -> void:
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if collider and collider.is_in_group("player"):
			animated_sprite_2d.play("falando")
			if not dialog_active:
				start_dialog()
	else:
		hide_dialog()

func _unhandled_input(event: InputEvent) -> void:
	if dialog_active and event.is_action_pressed("advance_message"):  # "ui_accept" = tecla Enter ou E
		next_dialog()

func start_dialog() -> void:
	dialog_active = true
	current_dialog_index = 0
	dialog_box.visible = true
	label.text = DIALOG_TEXTS[current_dialog_index]

func next_dialog() -> void:
	current_dialog_index += 1
	if current_dialog_index < DIALOG_TEXTS.size():
		label.text = DIALOG_TEXTS[current_dialog_index]
	else:
		hide_dialog()

func hide_dialog() -> void:
	dialog_active = false
	dialog_box.visible = false
	animated_sprite_2d.play("idle")
