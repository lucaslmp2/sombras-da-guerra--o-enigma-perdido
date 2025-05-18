extends TextureRect

var scale_factor = 4.0 # Fator de escala para o aumento
var original_scale = Vector2(1, 1) # Escala original da imagem

func _ready() -> void:
	# Salva a escala original
	original_scale = scale
	
func _on_mouse_entered() -> void:
	scale = original_scale * scale_factor
	z_index += 1

func _on_mouse_exited() -> void:
	# Restaura a escala original da imagem
	scale = original_scale
	z_index -= 1
