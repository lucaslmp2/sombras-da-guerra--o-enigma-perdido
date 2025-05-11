extends Area2D
@onready var porta: AudioStreamPlayer2D = $porta
@onready var saida: CollisionShape2D = $saida
@onready var animation_player: AnimationPlayer = $"../HUD/AnimationPlayer"

@onready var area_entrada: Area2D = get_node("../AreaEntrada") # Referência para a Area2D chamada "Entrada"
@export var player_layer: int = 1 # A layer do CollisionObject2D do seu player
@export var teleport_offset: float = 50.0 # Distância para se mover à frente (ajuste conforme necessário)
func _on_body_entered(body: Node2D) -> void:
	animation_player.play("fade_out")
	await get_tree().create_timer(0.5).timeout
	animation_player.play("fade_in")
	porta.play()
	if body.get_collision_layer_value(player_layer):
		if area_entrada and area_entrada.has_node("entrada"):
			var entrada_colisao = area_entrada.get_node("entrada") as CollisionShape2D # Obtém a CollisionShape2D
			var posicao_entrada = entrada_colisao.global_position
			var direcao_entrada = Vector2.RIGHT.rotated(entrada_colisao.global_rotation) # Assume que a "frente" local é para a direita

			# Calcula a nova posição à frente
			var nova_posicao = posicao_entrada + direcao_entrada * teleport_offset

			body.global_position = nova_posicao
func _on_npc_bryan_dialogo_inicial_terminou() -> void:
	saida.disabled = false # Replace with function body.
