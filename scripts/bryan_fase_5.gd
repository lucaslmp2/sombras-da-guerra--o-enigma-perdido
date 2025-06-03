extends StaticBody2D

@onready var hud: CanvasLayer = $"../../HUD"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var area_2d: CharacterBody2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
signal dialogo_inicial_terminou # Declara o sinal
var _dialog_instance: DialogScreen = null
var dialog_data_inicial: Dictionary = {
	0: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Olha a coisa tá feia por aqui.",
		"title": "Bryan"
	},
	1: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "As maquinás estão a todo o vapor.",
		"title": "Bryan"
	},
	2: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Agora já está quase no fim.",
		"title": "Elias"
	},
	3:{
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Esta fabrica está repleta de todos os tipos de inimigos.",
		"title": "Bryan"
	},
	4: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Pare a produção e ponha um fim a este plano diabolico.",
		"title": "Bryan"
	},
	5: {
		"faceset": "res://Assets/Prontos/face asset elias serio realista.png",
		"dialog": "Pode deixar.",
		"title": "Elias"
	},
	6: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Cuidado!!!",
		"title": "Bryan"
	}
}
var dialogo_saudacao: Dictionary = { # Dados do diálogo de saudação
	0: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Olá novamente!",
		"title": "Bryan"
	}
}

var dialogos_iniciais_exibidos: bool = false # Controla se os diálogos iniciais já foram mostrados
var dialogo_exibido_atual: bool = false # Controla se algum diálogo está sendo exibido no momento

func _show_dialog(dialog_data: Dictionary):
	if is_instance_valid(_dialog_instance):
		_dialog_instance.queue_free()
	_dialog_instance = DialogScreen.instantiate()
	_dialog_instance.data = dialog_data
	hud.add_child(_dialog_instance)
	dialogo_exibido_atual = true
	await _dialog_instance.tree_exited # Espera o diálogo ser fechado
	dialogo_exibido_atual = false
	

func _ready() -> void:
	animated_sprite_2d.play("idle")

func _process(delta: float) -> void:
	if ray_cast_2d.is_colliding() and not dialogo_exibido_atual:
		if not dialogos_iniciais_exibidos:
			_show_dialog(dialog_data_inicial)
			animated_sprite_2d.play("falando")
			dialogos_iniciais_exibidos = true # Marca que os diálogos iniciais foram exibidos

		else:
			emit_signal("dialogo_inicial_terminou") # Emite o sinal quando o diálogo inicial termina
			_show_dialog(dialogo_saudacao)
			animated_sprite_2d.play("falando")
			collision_shape_2d.disabled = true
	elif not ray_cast_2d.is_colliding():
		animated_sprite_2d.play("idle")
