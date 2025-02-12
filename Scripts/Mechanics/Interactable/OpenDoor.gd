extends Node3D

# Variables configurables
@export var action_name: String = "interact"
@export var detection_radius: float = 1.5
@export var texture_rect_node: TextureRect
@export var flag_requirement: String

# Referencia al jugador y cámara
@export var player: CharacterBody3D
@export var camera: Camera3D
@export var flags_manager: Node
@export var obj: Node3D
@export var rotation_amount: float = 90
@export var spawner: bool = false
@export var target_node: Node3D
@export var objects: Array[Node3D]

var screen_distance: float = 100.0
# Variables para la interpolación de rotación
var target_rotation: Vector3
var rotation_speed: float = 1.3  # Velocidad de interpolación
var is_rotated = false
var original_rotation
var open: bool = false

func _ready() -> void:
	if not player or not texture_rect_node or not camera:
		print("error: ", self.get_path())
		return
	original_rotation = rotation_degrees

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
			if flags_manager and flag_requirement != null and flags_manager.has_method(flag_requirement):
				if flags_manager.call(flag_requirement) == true:
					open = true
					texture_rect_node.queue_free()
					if spawner:
						spawn_object()
					is_rotated = !is_rotated
					target_rotation = original_rotation + Vector3(0, rotation_amount, 0) if is_rotated else original_rotation
			else:
				open = true
				texture_rect_node.queue_free()
				if spawner:
					spawn_object()
				is_rotated = !is_rotated
				target_rotation = original_rotation + Vector3(0, rotation_amount, 0) if is_rotated else original_rotation

	# Interpolación suave de la rotación (ease-out)
	if obj != null:
		obj.rotation_degrees = lerp(obj.rotation_degrees, target_rotation, delta * rotation_speed)

# Función para interpolación vectorial
func lerp_vector(start: Vector3, end: Vector3, weight: float) -> Vector3:
	return Vector3(
		lerp(start.y, end.y, weight)
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
