extends Area2D
@onready var porta: AudioStreamPlayer2D = $porta

@onready var area_porta: Area2D = get_node("../AreaSaida") # Referência para a Area2D chamada "Porta"
@export var player_layer: int = 1 # A layer do CollisionObject2D do seu player
@export var teleport_offset: float = 50.0 # Distância para se mover à frente (ajuste conforme necessário)
@onready var animation_player: AnimationPlayer = $"../HUD/AnimationPlayer"

# Called when another physics body enters the area.
func _on_body_entered(body: Node2D) -> void:
	animation_player.play("fade_out")
	await get_tree().create_timer(0.5).timeout
	animation_player.play("fade_in")
	porta.play()
	if body.get_collision_layer_value(player_layer):
		if area_porta and area_porta.has_node("saida"):
			var saida_colisao = area_porta.get_node("saida") as CollisionShape2D # Obtém a CollisionShape2D
			var posicao_saida = saida_colisao.global_position
			var direcao_saida = Vector2.LEFT.rotated(saida_colisao.global_rotation) # Assume que a "frente" local é para a direita

			# Calcula a nova posição à frente
			var nova_posicao = posicao_saida + direcao_saida * teleport_offset

			body.global_position = nova_posicao
