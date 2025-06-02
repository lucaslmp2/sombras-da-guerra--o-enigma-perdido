extends Area2D
@onready var hud: CanvasLayer = $"../../HUD"
const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
@onready var area_2d: Area2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $"../../porta/CollisionShape2D"

# Agrupando os NinePatchRects e Sprites para facilitar o controle
@onready var cell_visuals: Array[Node] = [
	$NinePatchRect13, $NinePatchRect14, $NinePatchRect15,
	$NinePatchRect22, $NinePatchRect23, $NinePatchRect24,
	$NinePatchRect, $NinePatchRect2, $NinePatchRect3,
	$NinePatchRect10, $NinePatchRect11, $NinePatchRect12,
	$Sprite2D, $Sprite2D2, $refens, $CollisionShape2D
]

var dialog_data: Dictionary={
	0:{
		"faceset":"res://Assets/Prontos/face_asset_mulher_sobrivivente.png",
		"dialog":"Socorro!!! Ajude-nos, Por favor!",
		"title":"Sobrevivente"
	},	
	1:{
		"faceset":"res://Assets/Prontos/face_asset_mulher_sobrivivente.png",
		"dialog":"Encontre a chave com o Rider e nos liberte!",
		"title":"Sobrevivente"
	},
}
@export_category("Objects")
var _dialog_instance: DialogScreen
var _dialog_shown: bool = false # Add this new variable

func _ready():
	# <<< AQUI ESTÁ A MUDANÇA PRINCIPAL >>>
	# Conecta diretamente ao SignalManager global
	SignalManager.chave_coletada.connect(_on_chave_coletada)
	print("Script da cela: Conectado ao SignalManager.chave_coletada!")
	collision_shape_2d.disabled = true

func _show_dialog(dialog_data: Dictionary):
	if is_instance_valid(_dialog_instance):
		_dialog_instance.queue_free()
	_dialog_instance = DialogScreen.instantiate()
	_dialog_instance.data = dialog_data
	hud.add_child(_dialog_instance)
	await _dialog_instance.tree_exited
	_dialog_shown = true

func _open_jail_animation():
	print("Animação de abertura das celas!")
	# Aqui você executaria sua animação de abertura.
	# Por exemplo, se você tivesse um AnimationPlayer:
	# $AnimationPlayer.play("open_jail")
	
	for node in cell_visuals:
		if is_instance_valid(node):
			node.visible = false # Torna o nó invisível
			# ou node.queue_free() # Se você quiser removê-los completamente
	
	# Se a própria Area2D da cela deve desaparecer ou ser desativada:
	# area_2d.queue_free() # Isso removeria o nó da cena.
	# Ou: area_2d.set_deferred("monitoring", false) # Desativa a detecção de colisão
	
	print("Celas abertas e visuais removidos!")

func _on_body_entered(body: Node2D) -> void:
	if not _dialog_shown:
		await _show_dialog(dialog_data)

# Este método será chamado quando o sinal 'chave_coletada' for emitido pelo SignalManager
func _on_chave_coletada():
	print("Sinal 'chave_coletada' recebido pelo script da cela! Abrindo celas...")
	_open_jail_animation()
	collision_shape_2d.disabled = false
