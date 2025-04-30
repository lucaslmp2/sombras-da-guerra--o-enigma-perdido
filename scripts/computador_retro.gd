extends Area2D

@onready var computador: AnimatedSprite2D = $Computador
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var maquina_ligada: AudioStreamPlayer2D = $Maquina_ligada
@onready var canhao: Area2D = $"../canhão"

signal desligar_canhão

var interagivel: bool = true

func _on_body_entered(body):
	if interagivel and body.has_method("_on_pendrive_coletado"): # Substitua "algum_metodo_de_interacao" pelo método real do seu player
		computador.play("ligado")
		maquina_ligada.play()
		interagivel = false # Impede interações repetidas até que o computador seja reiniciado (opcional)
		if is_instance_valid(canhao) and canhao.has_method("desligar"):
			canhao.desligar()
		else:
			push_error("Canhão não encontrado ou não tem o método 'ligar'.")

func _on_body_exited(body):
	# Opcional: Adicionar alguma lógica ao sair da área, se necessário
	pass

# Função para reiniciar o computador (opcional)
func reiniciar_computador():
	interagivel = true
	computador.play("desligado")
	maquina_ligada.stop()
	if is_instance_valid(canhao) and canhao.has_method("desligar"):
		canhao.desligar()
	else:
		push_error("Canhão não encontrado ou não tem o método 'desligar'.")
