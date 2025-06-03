extends Area2D

@onready var nine_patch_rect: NinePatchRect = $"../HUD/NinePatchRect" # Referência ao NinePatchRect
@onready var label_count: Label = $"../HUD/NinePatchRect/Label_count"
var enemy_deaths_counter: int = 0 # Variável para armazenar a contagem numérica
const MAX_DEATHS_FOR_PHASE_RESET: int = 10 # Define o limite para reiniciar a fase

# Chamado quando o nó entra na árvore de cena pela primeira vez.
func _ready() -> void:
	# Garante que o Label comece mostrando o valor inicial da sua contagem
	label_count.text = str(enemy_deaths_counter)

# Função para reiniciar o jogo/fase
func reload_game():
	# --- IMPORTANTE: Certifique-se de que 'Globals' é um Autoload (Singleton) ---
	# Vá em Project -> Project Settings -> Autoload e adicione um script chamado "Globals.gd"
	# com as variáveis que você quer persistir (ex: life, bullets, score).
	
	if Globals: # Verifica se o Autoload 'Globals' existe
		Globals.life = 3    # Reseta a vida para o valor inicial
		Globals.bulets = 10 # Reseta as balas para o valor inicial
		Globals.score = 0   # Reseta a pontuação para o valor inicial
		
	# Espera um pouco antes de recarregar a cena para dar um feedback visual ou permitir que algo aconteça
	await get_tree().create_timer(1.0).timeout 
	get_tree().reload_current_scene() # Recarrega a cena atual

# Função para fazer o NinePatchRect piscar
func _flash_nine_patch_rect():
	# Cria um novo Tween para animar as propriedades do NinePatchRect
	var tween = create_tween()
	tween.set_parallel(false) # Garante que as animações ocorram em sequência

	# Primeiro, faz o NinePatchRect brilhar um pouco (tintura mais clara/amarelada)
	# O Color(1.2, 1.2, 0.8, 1.0) significa um RGB ligeiramente acima de 1.0 para um efeito de brilho
	tween.tween_property(nine_patch_rect, "modulate", Color(1.2, 1.2, 0.8, 1.0), 0.05) # Duração de 0.05 segundos
	
	# Depois, faz ele voltar à cor original (branco opaco padrão para elementos UI)
	tween.tween_property(nine_patch_rect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15) # Duração de 0.15 segundos
	
	# Opcional: Repete o flash para um efeito mais pronunciado
	tween.tween_property(nine_patch_rect, "modulate", Color(1.2, 1.2, 0.8, 1.0), 0.05)
	tween.tween_property(nine_patch_rect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
	tween.tween_property(nine_patch_rect, "modulate", Color(1.2, 1.2, 0.8, 1.0), 0.05)
	tween.tween_property(nine_patch_rect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)


# Chamado quando um corpo entra na Area2D
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		enemy_deaths_counter += 1 # Incrementa a variável numérica
		label_count.text = str(enemy_deaths_counter) # Converte para string e atualiza o Label
		
		_flash_nine_patch_rect() # Chama a função para fazer o NinePatchRect piscar
		
		body.queue_free() # Remove o inimigo da cena
		
		# Verifica se a contagem atingiu o limite para reiniciar a fase
		if enemy_deaths_counter >= MAX_DEATHS_FOR_PHASE_RESET:
			reload_game() # Chama a função para reiniciar a fase
