extends Node2D
@onready var hud: CanvasLayer = $HUD
@onready var fade_layer: CanvasLayer = $FadeLayer
@onready var fade_rect: ColorRect = $FadeLayer/FadeRect
@onready var fade_anim: AnimationPlayer = $FadeLayer/FadeAnim
@export var next_scene: String = "res://Level/fase_2.tscn"
@export var menu_scene: String = "res://Level/main_menu.tscn"
@onready var computer_screen = $Computer_cena
@onready var ambiente: AudioStreamPlayer2D = $ambiente
@onready var colisao_pc: CollisionShape2D = $escritorio/decoração_escritorio/NinePatchRect4/computador/CollisionShape2D
const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
var dialog_data: Dictionary={
	0:{
		"faceset":"res://Assets/Prontos/face aset elias2 sorrindo.png",
		"dialog":"Uau! que dia Lindo!",
		"title":"Elias"
	},
	1:{
		"faceset":"res://Assets/Prontos/face aset elias2 sorrindo.png",
		"dialog":"Até que em fim cheguei no trabalho.",
		"title":"Elias"	
	},
	2:{
		"faceset":"res://Assets/Prontos/face aset elias2 sorrindo.png",
		"dialog":"Vamos lá! O que eu tenho que fazer primeiroooo...",
		"title":"Elias"	
	},
}
@export_category("Objects")

var _dialog_instance: DialogScreen # Use uma variável para armazenar a instância do diálogo

func _process(delta: float) -> void:
	pass

func _on_dialog_exited():
	_dialog_instance = null # Limpa a referência quando o diálogo é removido da cena
func _ready() -> void:
	fade_layer.visible = false
	ambiente.play()
	colisao_pc.disabled = true  # Desabilita a colisão até o pendrive ser coletado
	add_to_group("fase_atual") # Certifique-se de ter isso se estiver usando a Opção 2
	if _dialog_instance == null: # Verifica se não existe um diálogo já aberto
			_dialog_instance = DialogScreen.instantiate()
			_dialog_instance.data = dialog_data
			hud.add_child(_dialog_instance)
			_dialog_instance.connect("tree_exited", Callable(self, "_on_dialog_exited")) 
func _on_pendrive_coletado() -> void:
	print("Pendrive coletado, destravando PC!")
	# Use call_deferred para habilitar a colisão com segurança
	call_deferred("habilitar_colisao_pc")

func habilitar_colisao_pc() -> void:
	colisao_pc.disabled = false  # Habilita a colisão do computador

func _on_computer_screen_resposta_correta() -> void:
	fade_layer.visible = true
	get_tree().change_scene_to_file(next_scene)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)  # Volta para o menu principal

func _on_tela_fechada() -> void:
	if computer_screen:
		computer_screen.visible = false  # apenas oculta
