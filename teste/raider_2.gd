extends CharacterBody2D

# --- Node References ---
@onready var animation: AnimatedSprite2D = $anim
@onready var shot_marker: Marker2D = $Shot_marker # Assuming you'll add a Shot_marker node
@onready var ground_detector: RayCast2D = $ground_detector # Assuming you'll add a ground_detector RayCast2D
@onready var player_detector: RayCast2D = $player_detector # Assuming you'll add a player_detector RayCast2D
@onready var fire_timer: Timer = $FireTimer # Assuming you'll add a FireTimer node
@onready var shot_animation_timer: Timer = $ShotAnimationTimer # Assuming you'll add a ShotAnimationTimer node

# --- Sound References (Assuming you'll add these nodes) ---
@onready var hurt_sound: AudioStreamPlayer2D = $hurt
@onready var dead_sound: AudioStreamPlayer2D = $dead
@onready var walk_sound: AudioStreamPlayer2D = $walk
@onready var run_sound: AudioStreamPlayer2D = $run # If you plan to have a "run" animation/sound
@onready var shot_sound: AudioStreamPlayer2D = $shot

# --- Movement Properties ---
const SPEED = 150.0 # Adjusted speed to match the example enemy's `move_speed`
const JUMP_FORCE = -400.0 # Renamed for clarity to match player logic
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- Enemy Specific Properties ---
var health := 3
var direction := 1 # 1 for right, -1 for left
var original_shot_marker_position: Vector2

# --- State Variables ---
var is_jumping := false
var can_shoot := true
var is_shooting_animation_playing := false
var is_taking_damage := false
var is_dead := false
var knockback_vector := Vector2.ZERO # Still keep this if you have knockback mechanics

# --- Export Variables ---
@export var fire_rate := 1.0 # Interval between shots in seconds
@export var shot_animation_duration := 0.2 # Duration of the shot animation in seconds

# --- Preloaded Scenes ---
const bullet = preload("res://Prefabs/bullet_rider_1.tscn") # Make sure this path is correct

func _ready() -> void:
	# Initialize timers
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_timer_timeout)

	shot_animation_timer.wait_time = shot_animation_duration
	shot_animation_timer.one_shot = true
	shot_animation_timer.timeout.connect(_on_shot_animation_timer_timeout)

	# Store original shot marker position relative to the enemy
	if shot_marker: # Check if shot_marker exists to prevent errors
		original_shot_marker_position = shot_marker.position
	
	# Initial direction for the enemy
	animation.scale.x = direction


func _physics_process(delta: float) -> void:
	# If the enemy is dead or taking damage, stop all movement and actions
	if is_dead or is_taking_damage:
		velocity.x = 0
		move_and_slide()
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		is_jumping = true # The enemy is in the air, so it's "jumping" or falling
	else:
		is_jumping = false

	# Handle knockback if applicable (integrate with your existing knockback logic)
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
		# You might want to decay knockback_vector over time
		knockback_vector = knockback_vector.move_toward(Vector2.ZERO, delta * 500) # Example decay
	
	# --- Enemy Movement Logic ---
	# Turn around if hitting a wall
	if is_on_wall():
		change_direction()

	# Turn around if there's no ground ahead
	if not ground_detector.is_colliding() and is_on_floor():
		change_direction()

	# Set horizontal velocity for movement
	velocity.x = SPEED * direction

	# --- Animation and Sound Logic ---
	if player_detector.is_colliding() and can_shoot and not is_shooting_animation_playing:
		# Player detected and can shoot
		if animation.animation != "shot": # Only play if not already playing
			animation.play("shot")
		shot()
		can_shoot = false
		is_shooting_animation_playing = true
		fire_timer.start()
		shot_animation_timer.start()
	elif is_shooting_animation_playing:
		# Keep shot animation playing if still in timer
		if animation.animation != "shot":
			animation.play("shot")
	elif is_taking_damage:
		# Already handled at the start, but here for clarity if logic changes
		if animation.animation != "hurt":
			animation.play("hurt")
	elif is_dead:
		# Already handled at the start, but here for clarity if logic changes
		if animation.animation != "dead":
			animation.play("dead")
	elif is_on_floor():
		if velocity.x != 0:
			# Moving on ground
			if animation.animation != "walk":
				animation.play("walk")
			if not walk_sound.playing:
				walk_sound.play()
		else:
			# Standing still on ground
			if animation.animation != "idle":
				animation.play("idle")
			if walk_sound.playing:
				walk_sound.stop()
	else: # Not on floor (jumping/falling)
		if animation.animation != "jump": # Make sure you have a "jump" animation
			animation.play("jump")
		if walk_sound.playing:
			walk_sound.stop()

	move_and_slide()

# --- Helper Functions ---

func change_direction():
	direction *= -1
	animation.scale.x = direction # Flip sprite
	if player_detector:
		player_detector.scale.x = direction # Flip player detector
	if shot_marker:
		# Adjust shot marker position based on new direction
		shot_marker.position.x = original_shot_marker_position.x * sign(animation.scale.x)


func shot() -> void:
	if not bullet: return # Ensure bullet scene is loaded

	var new_bullet = bullet.instantiate()
	if shot_marker:
		new_bullet.global_position = shot_marker.global_position
		# Bullet direction based on enemy's facing direction
		new_bullet.velocity = Vector2(300 * sign(animation.scale.x), 0)
	else:
		# Fallback if shot_marker is not set up correctly
		new_bullet.global_position = global_position
		new_bullet.velocity = Vector2(300 * sign(animation.scale.x), 0)

	get_parent().add_child(new_bullet)
	if shot_sound:
		shot_sound.play()


func take_damage(damage_amount: int) -> void:
	if is_dead or is_taking_damage:
		return

	health -= damage_amount
	is_taking_damage = true

	if hurt_sound:
		hurt_sound.play()
	if animation:
		animation.play("hurt")

	# Wait for the hurt animation to finish before proceeding
	if animation and animation.is_node_ready(): # Check if animation node is ready
		await animation.animation_finished

	if health <= 0:
		if not is_dead:
			is_dead = true
			# Stop all processing and movement immediately
			set_physics_process(false)
			set_process(false)
			velocity = Vector2.ZERO

			# Play death animation and sound
			if is_instance_valid(animation):
				animation.play("dead")
				# Wait for a fixed time after playing dead animation, as per example
				await get_tree().create_timer(0.3).timeout
			
			if is_instance_valid(dead_sound):
				dead_sound.play()
			
			# Update score (assuming Globals exists)
			if "Globals" in self and Globals.has_method("add_score"):
				Globals.add_score(100) # Assuming you have a Globals script for score
			
			# Disable collision shapes
			if has_node("CollisionShape2D"):
				get_node("CollisionShape2D").disabled = true
			elif has_node("CollisionPolygon2D"): # Check for CollisionPolygon2D as well
				get_node("CollisionPolygon2D").disabled = true
			
			# Wait for the final delay before freeing the node
			await get_tree().create_timer(1.0).timeout
			queue_free()
	else:
		is_taking_damage = false


# --- Timer Callbacks ---

func _on_fire_timer_timeout():
	can_shoot = true

func _on_shot_animation_timer_timeout():
	is_shooting_animation_playing = false
	# After shot animation, transition back to idle or walk
	if is_on_floor() and velocity.x != 0:
		animation.play("walk")
	else:
		animation.play("idle")
