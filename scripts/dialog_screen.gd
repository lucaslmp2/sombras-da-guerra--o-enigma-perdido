extends Control
class_name DialogScreen

var _step: float = 0.05  # Velocidade de cada caractere
var _pause_after_finish: float = 1.5  # Tempo de pausa após frase completa
var _id: int = 0
var data: Dictionary = {}

@export_category("Objects")
@export var _name: Label = null
@export var _dialog: RichTextLabel = null
@export var _faceset: TextureRect = null

var _waiting_to_continue: bool = false

func _ready() -> void:
	_initialize_dialog()

func _process(delta: float) -> void:
	if _waiting_to_continue:
		return
	
	if _dialog.visible_ratio < 1:
		return

	_waiting_to_continue = true
	await get_tree().create_timer(_pause_after_finish).timeout
	
	_id += 1
	if _id == data.size():
		queue_free()
		return
	_initialize_dialog()
	_waiting_to_continue = false

func _initialize_dialog() -> void:
	_name.text = data[_id]["title"]
	_dialog.text = data[_id]["dialog"]
	_faceset.texture = load(data[_id]["faceset"])
	_dialog.visible_characters = 0
	
	while _dialog.visible_ratio < 1:
		await get_tree().create_timer(_step).timeout
		_dialog.visible_characters += 1
