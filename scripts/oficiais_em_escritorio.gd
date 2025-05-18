extends TextureRect

var scale_factor = 4.0
var original_scale = Vector2(1, 1)


func _ready() -> void:
	original_scale = scale

func _on_mouse_entered() -> void:
	scale = original_scale * scale_factor
	z_index += 1

func _on_mouse_exited() -> void:
	scale = original_scale
	z_index -= 1
