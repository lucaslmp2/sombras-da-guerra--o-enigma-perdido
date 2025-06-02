extends Control

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var label: Label = $NinePatchRect/Label
@onready var texture_button: TextureButton = $TextureButton

# Signal to emit when the card is closed
signal card_closed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the TextureButton's 'pressed' signal to a method in this script
	texture_button.pressed.connect(_on_texture_button_pressed)

# Called when the TextureButton is pressed
func _on_texture_button_pressed() -> void:
	emit_signal("card_closed") # Emit the signal
	queue_free() # Remove the card from the scene tree
