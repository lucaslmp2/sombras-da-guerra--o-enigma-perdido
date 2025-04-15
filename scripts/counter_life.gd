extends NinePatchRect
@onready var label: Label = $Label

func _ready() -> void:
	label.text = str("%02d" % Globals.life)
func _process(delta: float) -> void:
	if Globals.life <= 0:
		Globals.life = 0
	label.text = str("%02d" % Globals.life)
