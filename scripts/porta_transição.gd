extends Area2D

@export var next_level : = ""
@onready var collision: CollisionShape2D = $collision

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	collision.disabled = true


func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		TransitionLevel.destino_level = get_parent().name
		get_tree().call_deferred("change_scene_to_file", next_level)

func habilitar_colisao() -> void:
	collision.disabled = false
