extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
var body: CharacterBody2D = null
@onready var hud: CanvasLayer = $HUD
@export var menu_scene: String = "res://Level/main_menu.tscn"# Define a cena do menu principal
const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
@onready var locomotiva: Area2D = $Locomotiva
@onready var player: CharacterBody2D = $characters/Player
@onready var interface: Control = $HUD/Interface
@onready var porta_colisao: CollisionShape2D = $AreaSaida/saida# Pega a colisão da porta
@onready var animation_player: AnimationPlayer = $HUD/AnimationPlayer
@onready var oil_bublle: Area2D = $oleo/Oil_bublle
@onready var oil_bublle_2: Area2D = $oleo/Oil_bublle2
@onready var oil_bublle_3: Area2D = $oleo/Oil_bublle3
@onready var hurt_box_agua: Area2D = $agua/HurtBoxAgua
@onready var hurt_box_agua_5: Area2D = $agua/HurtBoxAgua5
@onready var hurt_box_agua_6: Area2D = $agua/HurtBoxAgua6
@onready var hurt_box_agua_2: Area2D = $agua/HurtBoxAgua2
@onready var hurt_box_agua_3: Area2D = $agua/HurtBoxAgua3
@onready var hurt_box_agua_4: Area2D = $agua/HurtBoxAgua4

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
func _ready() -> void:
	Globals.bulets = 0
	Globals.granada = 0
	Globals.life = 3
	Globals.score = 0
	Globals.pedra = 0
	player.player_died.connect(reload_game)
	animation_player.play("chegada")
	await animation_player.animation_finished
	oil_bublle.player_died.connect(reload_game)
	oil_bublle_2.player_died.connect(reload_game)
	oil_bublle_3.player_died.connect(reload_game)
	hurt_box_agua.player_died.connect(reload_game)
	hurt_box_agua_2.player_died.connect(reload_game)
	hurt_box_agua_3.player_died.connect(reload_game)
	hurt_box_agua_4.player_died.connect(reload_game)
	hurt_box_agua_5.player_died.connect(reload_game)
	hurt_box_agua_6.player_died.connect(reload_game)
	animation_player.play("night")
	#if _dialog_instance == null: # Verifica se não existe um diálogo já aberto
			#_dialog_instance = DialogScreen.instantiate()
			#_dialog_instance.data = dialog_data
			#hud.add_child(_dialog_instance)
			#_dialog_instance.connect("tree_exited", Callable(self, "_on_dialog_exited"))
	#_connect_dialogo_inicial_sinal() # Remova esta linha

func _on_dialog_exited():
	_dialog_instance = null # Limpa a referência quando o diálogo é removido da cena

func reload_game():
	Globals.life = 3 # **RESETA Globals.life AQUI**
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file(menu_scene)# Volta para o menu principal
