extends Node2D

@onready var fade_layer: CanvasLayer = $FadeLayer
@onready var fade_rect: ColorRect = $FadeLayer/FadeRect
@onready var fade_anim: AnimationPlayer = $FadeLayer/FadeAnim
@export var next_scene: String = "res://Level/fase_2.tscn"
@export var menu_scene: String = "res://Level/main_menu.tscn"
@onready var computer_screen = $Computer_cena
@onready var colisao_pc: CollisionShape2D = $escritorio/decoração_escritorio/NinePatchRect4/computador/CollisionShape2D

func _ready() -> void:
	fade_layer.visible = false
	colisao_pc.disabled = true  # Desabilita a colisão até o pendrive ser coletado
	add_to_group("fase_atual") # Certifique-se de ter isso se estiver usando a Opção 2

func _on_pendrive_coletado() -> void:
	print("Pendrive coletado, destravando PC!")
	# Use call_deferred para habilitar a colisão com segurança
	call_deferred("habilitar_colisao_pc")

func habilitar_colisao_pc() -> void:
	colisao_pc.disabled = false  # Habilita a colisão do computador

func _on_computer_screen_resposta_correta() -> void:
	fade_layer.visible = true
	fade_anim.play("fade_in")
	await fade_anim.animation_finished
	get_tree().change_scene_to_file(next_scene)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)  # Volta para o menu principal

func _on_tela_fechada() -> void:
	if computer_screen:
		computer_screen.visible = false  # apenas oculta
