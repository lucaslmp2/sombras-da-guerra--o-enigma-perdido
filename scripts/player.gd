extends CharacterBody2D

signal player_damaged(damage_amount)
signal player_died()

const SPEED = 200.0
const JUMP_FORCE = -300.0
@onready var marker_2d: Marker2D = $Marker2D
@export var grenade_scene: PackedScene = preload("res://Prefabs/granada2.tscn")
@export var bullet_scene : PackedScene = preload("res://Prefabs/Bullet.tscn") # Adiciona a cena da bala
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_jumping := false
var is_attacking := false
var player_life := Globals.life # Inicializa a vida do player com o valor global
var knockback_vector := Vector2.ZERO
var can_throw_grenade = true # Variável de controle
@onready var animation := $anim_inicial as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D

var is_na_tirolesa = false
var corda_path: Path2D = null
var path_follow_node: PathFollow2D = null
var velocidade_tirolesa = 0.0
var velocidade_maxima_tirolesa = 150.0 # Ajuste a velocidade conforme necessário
var aceleracao_tirolesa = 30.0 # Ajuste a aceleração conforme necessário
var distancia_para_soltar = 50.0 # Distância mínima para soltar ao final

func _ready():
	player_life = Globals.life
	print("PLAYER: Script do player iniciado.")

func throw_grenade():
	if can_throw_grenade and Globals.granada > 0:
		var grenade = grenade_scene.instantiate()
		grenade.position = global_position
		get_parent().add_child(grenade)

		var throw_direction = Vector2(1, -1) if animation.scale.x > 0 else Vector2(-1, -1)
		grenade.throw_grenade(throw_direction)
		Globals.granada -= 1
		if Globals.granada == 0:
			can_throw_grenade = false # Impede lançar se não houver granadas
	elif Globals.granada <= 0:
		can_throw_grenade = false # Garante que não tente lançar sem granadas

func disable_throwing():
	can_throw_grenade = false

func enable_throwing():
	can_throw_grenade = true

func _physics_process(delta):
	if is_attacking:
		return

	if is_na_tirolesa:
		process_tirolesa(delta)
		return # Impede o movimento normal enquanto estiver na tirolesa

	process_movimento_normal(delta)

	if Input.is_action_just_pressed("attack"):
		if Globals.granada > 0:
			await play_attack_animation("granade")
			throw_grenade()
	elif Input.is_action_just_pressed("attack_2"):
		attack_shot() # Change to attack_shot

	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector

	move_and_slide()

	for plataforms in get_slide_collision_count():
		var collision = get_slide_collision(plataforms)
		if collision.get_collider().has_method("has_collided_with"):
			collision.get_collider().has_collided_with(collision, self)

func process_movimento_normal(delta):
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
		if !is_jumping:
			animation.play("run_gangster")
	elif is_jumping:
		animation.play("jump_gangster")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animation.play("idle_gangster")

func process_tirolesa(delta):
	if corda_path and corda_path.has_node("PathFollow2D"):
		path_follow_node = corda_path.get_node("PathFollow2D")

		var direcao = Input.get_axis("ui_left", "ui_right")
		velocidade_tirolesa += direcao * aceleracao_tirolesa * delta
		velocidade_tirolesa = clamp(velocidade_tirolesa, -velocidade_maxima_tirolesa, velocidade_maxima_tirolesa)

		path_follow_node.progress += velocidade_tirolesa * delta
		global_position = path_follow_node.global_position

		# Soltar automaticamente ao chegar perto do final
		if path_follow_node.progress > corda_path.curve.get_baked_length() - distancia_para_soltar and velocidade_tirolesa > 0:
			soltar_tirolesa()
		elif path_follow_node.progress < distancia_para_soltar and velocidade_tirolesa < 0:
			soltar_tirolesa()

		# Soltar a tirolesa manualmente
		if Input.is_action_just_pressed("ui_accept"): # Usando a mesma tecla de pulo para soltar
			soltar_tirolesa()

func agarrar_tirolesa(corda):
	print("PLAYER: Função 'agarrar_tirolesa' chamada com a corda:", corda.name)
	if not is_na_tirolesa:
		is_na_tirolesa = true
		corda_path = corda
		velocidade_tirolesa = 0.0
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Guarda a gravidade original
		set_physics_process(true) # Garante que o _physics_process seja chamado
		velocidade_tirolesa = 100.0 # ou -100.0 dependendo do lado

		# Posiciona o player no ponto mais próximo do Path2D ao agarrar
		if corda_path.has_node("PathFollow2D"):
			path_follow_node = corda_path.get_node("PathFollow2D")
			
			# Corrige para pegar o ponto mais próximo sem extrapolar os limites da curva
			var offset = corda_path.curve.get_closest_offset(global_position)
			offset = clamp(offset, 0.0, corda_path.curve.get_baked_length())
			path_follow_node.progress = offset

			global_position = path_follow_node.global_position
			velocity = Vector2.ZERO # Zera a velocidade ao agarrar
			gravity = 0 # Desativa a gravidade enquanto na tirolesa
			is_jumping = false # Reseta o estado de pulo
			print("PLAYER: Player agarrou a tirolesa! corda_path:", corda_path.name, "path_follow_node:", path_follow_node.name)
		else:
			print("PLAYER: ERRO! 'PathFollow2D' não encontrado como filho de:", corda.name)
	else:
		print("PLAYER: Já está na tirolesa.")

func soltar_tirolesa():
	if is_na_tirolesa:
		is_na_tirolesa = false

		# Resetar PathFollow2D se ainda estiver válido
		if corda_path and corda_path.has_node("PathFollow2D"):
			var pf = corda_path.get_node("PathFollow2D")
			pf.progress = 0.0

		corda_path = null
		path_follow_node = null
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Restaura a gravidade

		# Aplica um pequeno impulso na direção do movimento (opcional)
		var impulso = Vector2(cos(rotation), sin(rotation)) * velocidade_tirolesa * 0.5
		velocity = impulso # Define a velocidade diretamente para o impulso
		print("PLAYER: Player soltou a tirolesa!")
	else:
		print("PLAYER: Não está na tirolesa para soltar.")

func play_attack_animation(attack_name: String):
	is_attacking = true
	animation.play(attack_name)
	await animation.animation_finished
	is_attacking = false

func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path

func take_damage(damage := 1, knockback_force := Vector2.ZERO, duration := 0.25):
	player_life -= damage
	Globals.life = player_life # Mantenha a vida global sincronizada com a vida do player ao receber dano
	play_attack_animation("hurt_gangster")
	emit_signal("player_damaged", damage)
	if player_life <= 0:
		play_attack_animation("dead_gangster")
		emit_signal("player_died")
		# Desabilita a colisão do player DEFERRED (CORRETO)
		if has_node("CollisionShape2D"):
			call_deferred("set", "get_node(\"CollisionShape2D\").disabled", true)
		elif has_node("CollisionPolygon2D"):
			call_deferred("set", "get_node(\"CollisionPolygon2D\").disabled", true)
		# Adicione outras formas de colisão que seu player possa ter aqui

	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		var knockback_tween := get_tree().create_tween()
		knockback_tween.tween_property(self, "knockback_vector", Vector2.ZERO, duration)

	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		var knockback_tween := get_tree().create_tween()
		knockback_tween.tween_property(self, "knockback_vector", Vector2.ZERO, duration)

func shoot():
	var bullet = bullet_scene.instantiate()
	Globals.bulets -= 1

	# Ajusta a posição da bala com base na escala horizontal do jogador
	bullet.position = global_position + Vector2(animation.scale.x * 20, -12) # Ajuste o valor 20 conforme necessário

	# Determina a direção do tiro com base na escala horizontal do player
	var direction = Vector2(animation.scale.x, 0).normalized()

	bullet.velocity = direction * 600
	get_parent().add_child(bullet)

func attack_shot():
	if Globals.bulets > 0:
		shoot()
		play_attack_animation("shot")

func pode_agarrar_tirolesa():
	return true # Adiciona este método para a verificação na Area2D da corda
