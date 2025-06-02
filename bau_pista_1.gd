extends Area2D
@export var item_scene: PackedScene = preload("res://Prefabs/pista_1.tscn") # Certifique-se de que esta cena é o seu NinePatchRect com Label
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var chest_open: AudioStreamPlayer2D = $chest_open
@onready var chest_close: AudioStreamPlayer2D = $chest_close
const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
var hud: CanvasLayer = null
var dialog_data2: Dictionary = {
	0: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Quase passou desapercebido.",
		"title": "Elias"
	},
}

var _dialog_instance: DialogScreen = null
var is_open = false
var _card_instance: Control = null # Variável para armazenar a instância da carta

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play("idle")
	var scene_root = get_tree().current_scene
	hud = scene_root.find_child("HUD", true, false)

func _on_body_entered(body):
	if body.is_in_group("player") and not is_open:
		await show_dialog_before_opening()

func _show_dialog(dialog_data2: Dictionary):
	if is_instance_valid(_dialog_instance):
		_dialog_instance.queue_free()
	_dialog_instance = DialogScreen.instantiate()
	_dialog_instance.data = dialog_data2
	hud.add_child(_dialog_instance)
	await _dialog_instance.tree_exited # Espera o diálogo ser fechado (quando for removido da árvore)

func show_dialog_before_opening():
	is_open = true
	await _show_dialog(dialog_data2) # Mostra e espera o diálogo terminar
	chest_open.play()
	sprite.play("open")
	await sprite.animation_finished # Espera a animação terminar
	spawn_card() # Chamamos spawn_card

func spawn_card():
	if item_scene:
		_card_instance = item_scene.instantiate()
		if _card_instance is Control: # Verifica se é um Control
			hud.add_child(_card_instance) # Adiciona à HUD
			
			# Centraliza a carta na tela
			var viewport_size = get_viewport_rect().size
			_card_instance.position = (viewport_size - _card_instance.size) / 2
			
			# AGUARDA O SINAL 'card_closed' EMITIDO PELA CARTA
			# A execução do spawn_card() será pausada aqui até que a carta emita esse sinal.
			await _card_instance.card_closed 
			
			# Após o sinal ser emitido (e a carta já ter sido liberada por si mesma)
			_card_instance = null # Limpa a referência

		else:
			print("Erro: item_scene não é um Control (NinePatchRect/Label)! Verifique a cena 'carta.tscn'.")
	else:
		print("Erro: item_scene não está definido. Verifique a export var 'item_scene'.")

# Remova esta função, pois a lógica de fechamento agora está na própria carta
# e o baú aguarda o sinal diretamente.
# func _on_card_closed():
# 	if is_instance_valid(_card_instance):
# 		_card_instance.queue_free()
# 		_card_instance = null

# Remova ou comente a função spawn_item original se não for mais utilizada
# func spawn_item():
# 	if item_scene:
# 		var item_instance = item_scene.instantiate()
# 		if item_instance is Area2D:
# 			item_instance.global_position = global_position + Vector2(0, -40)
# 			get_parent().get_parent().add_child(item_instance)
# 			item_instance.add_to_group("disfarce")
# 			if get_parent().get_parent().has_node("AreaSaida2"):
# 				var area_saida_node = get_parent().get_parent().get_node("AreaSaida2")
# 				item_instance.connect("camisa_coletada", Callable(area_saida_node, "_on_disfarce_coletado"))
# 			else:
# 				printerr("Erro: Nó 'AreaSaida2' não encontrado!")
# 		else:
# 			print("Erro: item_scene não é um Area2D!")
