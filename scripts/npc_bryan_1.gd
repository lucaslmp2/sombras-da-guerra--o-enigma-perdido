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
		"faceset": "res://Assets/Prontos/elias_face_asset_realista.png",
		"dialog": "O que? Onde... onde é que estou? Quem é você?",
		"title": "Elias"
	},
	1: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Calma, Elias. Você foi teletransportado para um território hostil.",
		"title": "Bryan"
	},
	2: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Ainda é cedo pra explicar tudo, mas você tem uma missão.",
		"title": "Bryan"
	},
	3:{
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Você precisa se disfarçar para passar despercebido. Existem baús espalhados pelas estações.",
		"title": "Bryan"
	},
	4: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Neles, há cinco peças: camisa, calça, capuz, chapéu e uma arma.",
		"title": "Bryan"
	},
	5: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Mas cuidado! Patrulhas hostis estão por toda parte e não hesitarão em te eliminar.",
		"title": "Bryan"
	},
	6: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Colete pedras pelo caminho. Pressione a tecla '4' para lançá-las e eliminar os inimigos.",
		"title": "Bryan"
	},
	7: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Use as setas para 'esquerda' e 'direita' para se mover. Pressione 'Espaço' para pular.",
		"title": "Bryan"
	},
	8: {
		"faceset": "res://Assets/Prontos/bryan_npc.png",
		"dialog": "Depois de se equipar, pegue o trem até o final da fase. É o único jeito de sair daqui.",
		"title": "Bryan"
	},
	9: {
		"faceset": "res://Assets/Prontos/elias_face_asset_realista.png",
		"dialog": "Certo... não sei o que tá acontecendo, mas vou confiar em você por enquanto.",
		"title": "Elias"
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
