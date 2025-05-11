extends StaticBody2D

@onready var hud: CanvasLayer = $"../../HUD"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DialogScreen: PackedScene = preload("res://Prefabs/dialog_screen.tscn")
signal dialogo_inicial_terminou # Declara o sinal
var _dialog_instance: DialogScreen = null
var dialog_data_inicial: Dictionary = {
	0: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "E aí? Coletou todos as peças do seu disfarce?",
		"title": "Bryan"
	},
	1: {
		"faceset": "res://Assets/Prontos/elias_face_asset_realista.png",
		"dialog": "Acredito que sim.",
		"title": "Elias"
	},
	2: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Ótimo! siga em frente para se trocar.",
		"title": "Bryan"
	},
	3:{
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "As coisas daqui pra frente vão ficar um pouco complicadas.",
		"title": "Bryan"
	},
	4: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Os inimigos que você vai encontrar á frente.",
		"title": "Bryan"
	},
	5: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Vão fazer de tudo para acabar com você.",
		"title": "Bryan"
	},
	6: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Uma ordem chamada Cruz Negra está tornando os dias mais díficeis.",
		"title": "Bryan"
	},
	7: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Eles querem implementar um regime Nazifacista a todo custo.",
		"title": "Bryan"
	},
	8: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Eles são comandados pelo Major Klaus Reinhardt.",
		"title": "Bryan"
	},
	9: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Um dos comandados de Adolf.",
		"title": "Bryan"
	},
	10:{
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "São tempos sombrios meu amigo.",
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
	elif not ray_cast_2d.is_colliding():
		animated_sprite_2d.play("idle")
