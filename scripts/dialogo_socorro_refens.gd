extends Area2D
@onready var hud: CanvasLayer = $"../../HUD" # Caminho relativo, certifique-se de que está correto!
const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
@onready var area_2d: Area2D = $"." # Isso se refere ao próprio nó Area2D da cela, provavelmente você quer que ele seja removido ou desativado.

# Agrupando os NinePatchRects e Sprites para facilitar o controle
@onready var cell_visuals: Array[Node] = [
	$NinePatchRect13, $NinePatchRect14, $NinePatchRect15,
	$NinePatchRect22, $NinePatchRect23, $NinePatchRect24,
	$NinePatchRect, $NinePatchRect2, $NinePatchRect3,
	$NinePatchRect10, $NinePatchRect11, $NinePatchRect12,
	$Sprite2D, $Sprite2D2
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
	# Encontra o nó da chave e conecta o sinal 'pick_up_chave'
	var key_node = get_tree().current_scene.find_child("Key", true, false) # Substitua "Key" pelo nome real do seu nó de chave na cena principal
	if key_node:
		key_node.pick_up_chave.connect(_on_chave_coletada)
		print("Sinal 'pick_up_chave' conectado com sucesso!")
	else:
		printerr("ERRO: Nó da chave (Key) não encontrado para conectar o sinal!")

func _show_dialog(dialog_data: Dictionary):
	if is_instance_valid(_dialog_instance):
		_dialog_instance.queue_free()
	_dialog_instance = DialogScreen.instantiate()
	_dialog_instance.data = dialog_data
	hud.add_child(_dialog_instance)
	await _dialog_instance.tree_exited # Aguarda o diálogo ser fechado antes de continuar
	_dialog_shown = true # Define como true após o diálogo terminar
	
func _open_jail_animation():
	print("Animação de abertura das celas!")
	# Aqui você executaria sua animação de abertura.
	# Por exemplo, se você tivesse um AnimationPlayer:
	# $AnimationPlayer.play("open_jail")
	
	# Para fazer os NinePatchRects e Sprites desaparecerem:
	for node in cell_visuals:
		if is_instance_valid(node):
			node.visible = false # Torna o nó invisível
			# ou node.queue_free() # Se você quiser removê-los completamente
	
	# Se a própria Area2D da cela deve desaparecer ou ser desativada:
	# area_2d.queue_free() # Isso removeria o nó da cena.
	# Ou: area_2d.set_deferred("monitoring", false) # Desativa a detecção de colisão
	# Ou: area_2d.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED) # Desativa processamento
	
	print("Celas abertas e visuais removidos!")

func _on_body_entered(body: Node2D) -> void:
	if not _dialog_shown: # Só mostra o diálogo se não foi mostrado ainda
		await _show_dialog(dialog_data) # Aguarda o diálogo ser fechado

# Este método será chamado quando o sinal 'pick_up_chave' for emitido
func _on_chave_coletada():
	print("Sinal 'pick_up_chave' recebido! Abrindo celas...")
	_open_jail_animation() # Chama a função para abrir as celas
