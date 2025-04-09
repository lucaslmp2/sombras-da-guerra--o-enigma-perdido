extends NinePatchRect
@onready var label: Label = $score

func _ready() -> void:
	label.text = str("%03d" % Globals.life)
