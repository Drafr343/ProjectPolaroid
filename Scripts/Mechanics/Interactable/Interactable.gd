extends Node3D

# Variables configurables
@export var action_name: String = "interact"
@export var detection_radius: float = 3
@export var screen_distance: float = 200.0  # Distancia máxima desde el centro de la pantalla
@export var function_name: String
@export var flag_requirement: String

# Referencias a nodos
@export var texture_rect_node: TextureRect
@export var flags_manager: Node
@export var spawner: bool = false
@export var target_node: Node3D
@export var object: Node3D

# Referencia al jugador y cámara
@export var player: CharacterBody3D
@export var camera: Camera3D

func _ready() -> void:
	if not player or not texture_rect_node or not camera:
		print("error: ", self.get_path())
		return

func _process(delta):
	if not player or not texture_rect_node or not camera:
		return

	# Calcular la distancia del objeto al jugador
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)

	# Proyectar la posición del objeto en la pantalla
	var screen_position = camera.unproject_position(global_transform.origin)

	# Verificar si el objeto está visible en la pantalla
	var object_on_screen = camera.is_position_behind(global_transform.origin) == false
	var screen_center = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)
	var distance_to_screen_center = screen_center.distance_to(screen_position)

	# Mostrar u ocultar la Label si ambas condiciones se cumplen
	if distance_to_player <= detection_radius and distance_to_screen_center <= screen_distance and object_on_screen:
		# Verificar si se presiona la acción cuando está dentro del rango
		if Input.is_action_just_pressed(action_name):
			if flags_manager and flags_manager.has_method(function_name):
				if flag_requirement != null and flags_manager.has_method(flag_requirement):
					if flags_manager.call(flag_requirement) == true:
						flags_manager.call(function_name) #Llama la funcion
						if spawner:
							spawn_object()
				else:
					flags_manager.call(function_name) #Llama la funcion
					if spawner:
						spawn_object()

func spawn_object():
	# Make the object a child of the target node
	object.get_parent().remove_child(object)
	target_node.add_child(object)

	# Reset its position relative to the target node
	object.transform.origin = Vector3.ZERO
	print("Moved object: ", object.name, " to position: ", target_node.global_transform.origin)
	return
