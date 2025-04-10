extends NinePatchRect
@onready var label: Label = $score

func _ready() -> void:
	label.text = str("%06d" % Globals.score)
func _process(delta: float) -> void:
	label.text = str("%6d" % Globals.score)
