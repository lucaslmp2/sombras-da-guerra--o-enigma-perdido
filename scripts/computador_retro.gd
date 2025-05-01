extends Area2D

@onready var computador: AnimatedSprite2D = $Computador
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var maquina_ligada: AudioStreamPlayer2D = $Maquina_ligada
@onready var canhao: Area2D = $"../canhão"
signal desligar_canhao
@onready var alavanca_de_computador: CanvasLayer = $Alavanca_de_computador
@onready var animated_sprite_2d: AnimatedSprite2D = $Alavanca_de_computador/Control/AnimatedSprite2D

func _ready() -> void:
	maquina_ligada.play()
	computador.play("ligado")

	# Conectar o sinal usando Callable (Godot 4)
	if not is_connected("desligar_canhao", Callable(canhao, "_on_Canhao_desligar_canhao")):
		connect("desligar_canhao", Callable(canhao, "_on_Canhao_desligar_canhao"))


func _on_body_entered(body):
	if body.name == "Player":  # ou outro critério de identificação
		if is_instance_valid(canhao) and canhao.has_method("desligar"):
			emit_signal("desligar_canhao")
			computador.play("desligado")
			maquina_ligada.stop()
			
			# Mostrar alavanca
			alavanca_de_computador.visible = true
			animated_sprite_2d.play("alavanca")  # Certifique-se que a animação se chama assim

			await get_tree().create_timer(0.8).timeout

			# Esconder a alavanca novamente
			alavanca_de_computador.visible = false
		else:
			push_error("Canhão não encontrado ou não tem o método 'desligar'.")
