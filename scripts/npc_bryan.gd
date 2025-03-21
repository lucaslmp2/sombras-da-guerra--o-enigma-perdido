extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

func _ready() -> void:
	animated_sprite_2d.play("idle")

func _process(_delta: float) -> void:
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider().is_in_group("player"):
		animated_sprite_2d.play("falando")
	else:
		animated_sprite_2d.play("idle")
	#if ray_cast_2d.is_colliding():
		
