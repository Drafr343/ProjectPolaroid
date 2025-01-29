extends Node3D
# Variables configurables
@export var action_name: String = "interact"
@export var detection_radius: float = 1.5
var screen_distance: float = 100.0 
@export var texture_rect_node: TextureRect
# Referencia al jugador y cámara
@export var player: CharacterBody3D
@export var camera: Camera3D
@export var translation_amount: Vector3  # Vector3 para translations en 3 ejes
@export var spawner: bool = false
@export var target_node: Node3D
@export var objects: Array[Node3D]

# Variables para la interpolación de translación
var target_translation: Vector3
var translation_speed: float = 2.5  # Velocidad de interpolación
var is_translated = false
var original_translation: Vector3
var open: bool = false

func _ready() -> void:
	if not player or not texture_rect_node or not camera:
		print("error: ", self.get_path())
		return
	if objects.is_empty() and spawner:
		print("No objects in the array.")
		return
	if not target_node and spawner:
		print("Target node is not set.")
		return
	# Store the initial local position explicitly
	original_translation = Vector3(position)
	# Initialize target translation to the original position
	target_translation = original_translation

func _process(delta):
	if not player or not camera:
		return
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	var screen_position = camera.unproject_position(global_transform.origin)
	var object_on_screen = camera.is_position_behind(global_transform.origin) == false
	var screen_center = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)
	var distance_to_screen_center = screen_center.distance_to(screen_position)
	
	# Mostrar u ocultar la Label si ambas condiciones se cumplen
	if distance_to_player <= detection_radius and distance_to_screen_center <= screen_distance and object_on_screen:
		# Verificar si se presiona la acción cuando está dentro del rango
		if Input.is_action_just_pressed(action_name) and !open:
			open = true
			texture_rect_node.queue_free()
			if spawner:
				spawn_object()
			is_translated = !is_translated
			target_translation = original_translation + translation_amount if is_translated else original_translation
	# Interpolación suave de la translación (ease-out)
	position = lerp_vector(position, target_translation, delta * translation_speed)

# Función para interpolación vectorial
func lerp_vector(start: Vector3, end: Vector3, weight: float) -> Vector3:
	return Vector3(
		lerp(start.x, end.x, weight),
		lerp(start.y, end.y, weight),
		lerp(start.z, end.z, weight)
	)

func spawn_object():
	var random_object = objects[randi() % objects.size()]
	# Make the selected object a child of the target node
	random_object.get_parent().remove_child(random_object)
	target_node.add_child(random_object)

	# Reset its position relative to the target node
	random_object.transform.origin = Vector3.ZERO
	print("Moved object: ", random_object.name, " to position: ", target_node.global_transform.origin)
	return
