extends Node3D
class_name Arma

@export var tamano_cargador: int = 30
@export var municion_actual: int = 30
@export var municion_inventario: int = 90

@export var dano_por_disparo: float = 10.0
@export var perdida_dano_por_distancia: float = 0.1

@export var es_tiro_unico: bool = true
@export var es_automatica: bool = true
@export_enum("Auto", "Semi") var modo_disparo = "Auto"

@export var recoil_vertical: float = 5.0
@export var recoil_horizontal: float = 2.0
@export var multiplicador_apuntado: float = 0.5

@export var tiempo_recarga: float = 2.0
@export var tasa_disparo: float = 0.2

@export var player: Node3D
@export var player_camera: Camera3D

var puede_disparar: bool = true
var base_recoil_vertical: float = 0.0
var base_recoil_horizontal: float = 0.0

var is_aiming: bool = false
var last_interact_time: float = 0.0
var interact_threshold: float = 0.3

var tiempo_total: float = 0.0

# Modified camera variables
var camera_initial_rotation: Vector3
var current_recoil: float = 0.0
var recoil_recovery_rate: float = 10.0
var is_shooting: bool = false
var is_reloading: bool = false
var trigger_reset: bool = true  # New: Track if trigger has been reset for semi-auto

func _ready() -> void:
	base_recoil_vertical = recoil_vertical
	base_recoil_horizontal = recoil_horizontal
	set_process_input(true)
	set_process(true)
	if player_camera:
		camera_initial_rotation = player_camera.rotation_degrees
		print("Camera initialized at rotation: ", camera_initial_rotation)
	print("Arma iniciada en modo: ", "Automático" if es_automatica else "Semi-automático")

func _process(delta: float) -> void:
	tiempo_total += delta
	
	if current_recoil > 0:
		current_recoil = max(0, current_recoil - (recoil_recovery_rate * delta))
		if player_camera:
			var target_rotation = camera_initial_rotation.x - current_recoil
			player_camera.rotation_degrees.x = lerp(player_camera.rotation_degrees.x, target_rotation, delta * 5.0)
			if current_recoil == 0:
				print("Recoil fully recovered")
	
	# Modified shooting logic
	if is_shooting and puede_disparar:
		if es_automatica or (not es_automatica and trigger_reset):
			var target: Vector3 = global_transform.origin + (-global_transform.basis.z * 100.0)
			disparar(target)
			if not es_automatica:
				trigger_reset = false  # Prevent semi-auto from firing again until trigger is released

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("aim"):
		is_aiming = true
		apuntar(true)
	elif event.is_action_released("aim"):
		is_aiming = false
		apuntar(false)
	
	# Modified shooting input logic
	if event.is_action_pressed("shoot"):
		is_shooting = true
		if not es_automatica:
			print("Semi-auto trigger pressed")
	elif event.is_action_released("shoot"):
		is_shooting = false
		trigger_reset = true  # Reset trigger only when released
		print("Trigger released - Reset for next shot")
	
	if event.is_action_pressed("toggle_fire_mode"):
		toggle_fire_mode()
	
	if event.is_action_pressed("interact"):
		var current_time: float = tiempo_total
		if is_aiming:
			intentar_recargar()
		else:
			if current_time - last_interact_time < interact_threshold:
				intentar_recargar()
			last_interact_time = current_time

func toggle_fire_mode() -> void:
	es_automatica = !es_automatica
	modo_disparo = "Auto" if es_automatica else "Semi"
	trigger_reset = true  # Reset trigger state when changing modes
	print("Modo de disparo cambiado a: ", "Automático" if es_automatica else "Semi-automático")

# Rest of the functions remain the same...
func apuntar(apuntando: bool) -> void:
	if apuntando:
		recoil_vertical = base_recoil_vertical * multiplicador_apuntado
		recoil_horizontal = base_recoil_horizontal * multiplicador_apuntado
		print("Apuntando: recoil reducido a vertical:", recoil_vertical, " horizontal:", recoil_horizontal)
	else:
		recoil_vertical = base_recoil_vertical
		recoil_horizontal = base_recoil_horizontal
		print("No se apunta: recoil restaurado a vertical:", recoil_vertical, " horizontal:", recoil_horizontal)

func intentar_recargar() -> void:
	if is_reloading:
		print("Ya está recargando, espere...")
		return
	recargar()

func recargar() -> void:
	if municion_inventario > 0 and municion_actual < tamano_cargador and not is_reloading:
		is_reloading = true
		var balas_necesarias: int = tamano_cargador - municion_actual
		var balas_a_recargar: int = min(balas_necesarias, municion_inventario)
		print("Iniciando recarga...")
		
		await get_tree().create_timer(tiempo_recarga).timeout
		
		balas_a_recargar = min(balas_a_recargar, municion_inventario)
		if balas_a_recargar > 0:
			municion_actual += balas_a_recargar
			municion_inventario -= balas_a_recargar
			print("Recarga completa. Munición actual:", municion_actual, " Inventario:", municion_inventario)
		
		is_reloading = false
	else:
		if is_reloading:
			print("Ya está recargando, espere...")
		else:
			print("No es posible recargar: cargador lleno o inventario vacío.")

func disparar(posicion_objetivo: Vector3) -> void:
	if not puede_disparar or municion_actual <= 0 or is_reloading:
		if municion_actual <= 0:
			print("Sin munición en el cargador. Recarga necesaria.")
		return

	municion_actual -= 1
	var distancia: float = global_transform.origin.distance_to(posicion_objetivo)
	var dano_final: float = max(0, dano_por_disparo - (perdida_dano_por_distancia * distancia))
	
	var recoil_random_horizontal: float = randf_range(-recoil_horizontal, recoil_horizontal)
	if player:
		player.rotate_y(deg_to_rad(recoil_random_horizontal))
		print("Recoil horizontal aplicado:", recoil_random_horizontal)
	
	if player_camera:
		var recoil_value: float = randf_range(recoil_vertical * 0.5, recoil_vertical)
		current_recoil += recoil_value
		
		var current_rotation = player_camera.rotation_degrees.x
		var peak_recoil = current_rotation - recoil_value
		
		var tween = get_tree().create_tween()
		tween.tween_property(player_camera, "rotation_degrees:x", peak_recoil, 0.05)
		print("Recoil vertical aplicado:", recoil_value, " Camera rotation:", peak_recoil)
	
	print("Disparo efectuado. Daño calculado:", dano_final, " Munición restante:", municion_actual)
	
	if not es_tiro_unico:
		var cantidad_perdigones: int = 6
		for i in range(cantidad_perdigones):
			var pellet_dano: float = dano_final / 2.0
			print("Perdigón", i + 1, "daño:", pellet_dano)
	
	Input.start_joy_vibration(0, 0.5, 0.5, 0.1)
	
	puede_disparar = false
	await get_tree().create_timer(tasa_disparo).timeout
	puede_disparar = true
	print("Arma lista para siguiente disparo")

func agregar_municion(cantidad: int) -> void:
	municion_inventario += cantidad
	print("Se agregaron", cantidad, "balas al inventario. Total inventario:", municion_inventario)
