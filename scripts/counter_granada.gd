extends NinePatchRect
@onready var label: Label = $Label

func _ready() -> void:
	label.text = str("%02d" % Globals.granada)
func _process(delta: float) -> void:
	label.text = str("%02d" % Globals.granada)
