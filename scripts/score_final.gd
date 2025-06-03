extends Label

@onready var label: Label = $"."

func _ready() -> void:
	label.text = str("%06d" % Globals.score)
func _process(delta: float) -> void:
	label.text = str("%6d" % Globals.score)
