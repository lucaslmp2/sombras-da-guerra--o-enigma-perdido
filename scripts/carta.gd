extends Control

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var label: Label = $NinePatchRect/Label
@onready var texture_button: TextureButton = $TextureButton

# Signal to emit when the card is closed
signal card_closed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Saudações, meu caro adversário,\n\n" + \
				 "Enquanto tu te banhas na ilusão da vitória iminente,\n" + \
				 "eu teço nas sombras uma teia de segredos que mudará o rumo deste\n" + \
				 "conflito para sempre.\n" + \
				 "As engrenagens da minha conspiração já giram, invisíveis aos\n" + \
				 "teus olhos, e quando o momento certo chegar,\n" + \
				 "os ventos da guerra soprarão em direção\n" + \
				 "ao Reich que renasce.\n\n" + \
				 "Os mapas que tu acreditas dominar são apenas peças de um\n" + \
				 "jogo maior, e em breve verás que cada linha,\n" + \
				 "cada fronteira, cada trincheira foi desenhada\n" + \
				 "com o sangue da traição. Há aliados disfarçados de inimigos,\n" + \
				 "e inimigos que se sentam à tua mesa.\n\n" + \
				 "Não me subestime. Eu sou o eco sombrio que se esconde nas\n" + \
				 "ruínas do teu fracasso.\n" + \
				 "Eu sou o arquiteto do novo Reich, e em breve tu saberás o peso\n" + \
				 "da palavra 'derrota'.\n\n" + \
				 "Atenciosamente, \n" + \
				 "O Orquestrador das Sombras"
	
	# Connect the TextureButton's 'pressed' signal to a method in this script
	texture_button.pressed.connect(_on_texture_button_pressed)

# Called when the TextureButton is pressed
func _on_texture_button_pressed() -> void:
	emit_signal("card_closed") # Emit the signal
	queue_free() # Remove the card from the scene tree
