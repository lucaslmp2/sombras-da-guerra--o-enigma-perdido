extends CharacterBody2D

const SPEED = 200.0
const JUMP_FORCE = -250.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping := false
var player_life := 10
var knockback_vector := Vector2.ZERO

@onready var animation := $AnimatedSprite2D as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		is_jumping = true
	elif is_on_floor():
		is_jumping = false

	var direction = Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction
		if !is_jumping: #if is_not jumping
			animation.play("correr")
	elif is_jumping: #is_jumping == true
		animation.play("pulo")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animation.play("idle")
		
		
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
		
	move_and_slide()
	
#func _on_hurtbox_body_entered(body: Node2D) -> void:
	##if body.is_in_group("enemies"):
		##queue_free()
	#if player_life < 0:
		#queue_free()
	#else:
		#take_damage(Vector2(200, -200))

func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path

func take_damage(knockback_force := Vector2.ZERO, duration := 0.25):
	player_life -= 1
	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		
		var knockback_tween := get_tree().create_tween()
		knockback_tween.tween_property(self, "knockback_vector", Vector2.ZERO, duration)
