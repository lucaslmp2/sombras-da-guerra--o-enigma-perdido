extends Node2D
class_name Level_2
@onready var hud: CanvasLayer = $HUD
@onready var player: CharacterBody2D = $character/Player
@onready var interface: Control = $HUD/Interface
@onready var raider_1: CharacterBody2D = $raider_1
@onready var agua: Node2D = $Agua/HurtBoxAgua
@onready var queda: Node2D = $Agua/Queda_livre
@onready var queda2: Node2D = $Agua/Queda_livre2
@onready var ambiente_açao: AudioStreamPlayer2D = $ambiente_açao
@onready var colisao_pc: CollisionShape2D = $computador/Computador_retro/CollisionShape2D
@export var menu_scene: String = "res://Level/main_menu.tscn"# Define a cena do menu principal
@onready var computador_retro: Area2D = $computador/Computador_retro

const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
var dialog_data: Dictionary={
	0:{
		"faceset":"res://Assets/Prontos/face aset elias asustado.png",
		"dialog":"O que eu vou fazer agora?",
		"title":"Elias"
	},	
	1:{
		"faceset":"res://Assets/Prontos/face aset elias asustado.png",
		"dialog":"Há muitos inimigos por aqui!",
		"title":"Elias"
	},
}
@export_category("Objects")

var _dialog_instance: DialogScreen # Use uma variável para armazenar a instância do diálogo

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if _dialog_instance == null: # Verifica se não existe um diálogo já aberto
			_dialog_instance = DialogScreen.instantiate()
			_dialog_instance.data = dialog_data
			hud.add_child(_dialog_instance)
			_dialog_instance.connect("tree_exited", Callable(self, "_on_dialog_exited")) # Conecta um sinal para limpar a referência

func _on_dialog_exited():
	_dialog_instance = null # Limpa a referência quando o diálogo é removido da cena

func _on_pendrive_coletado() -> void:
	print("Pendrive coletado, destravando PC!")
	# Use call_deferred para habilitar a colisão com segurança
	call_deferred("habilitar_colisao_pc")

func habilitar_colisao_pc() -> void:
	colisao_pc.disabled = false  # Habilita a colisão do computador

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)  # Volta para o menu principal

func _ready() -> void:
	Globals.bulets = 100
	Globals.granada = 3
	Globals.life = 3
	Globals.score = 0
	player.player_died.connect(reload_game)
	agua.player_died.connect(reload_game)
	queda.player_died.connect(reload_game)
	queda2.player_died.connect(reload_game)
	ambiente_açao.play()
	colisao_pc.disabled = true  # Desabilita a colisão até o pendrive ser coletado
	if _dialog_instance == null: # Verifica se não existe um diálogo já aberto
			_dialog_instance = DialogScreen.instantiate()
			_dialog_instance.data = dialog_data
			hud.add_child(_dialog_instance)
			_dialog_instance.connect("tree_exited", Callable(self, "_on_dialog_exited"))
	# Conecta o sinal do item à função da fase

func reload_game():
	Globals.life = 3 # **RESETA Globals.life AQUI**
	await   get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func _on_computador_retro_desligar_canhao() -> void:
	computador_retro.desligar_canhao.connect("_on_Canhao_desligar_canhao")		
