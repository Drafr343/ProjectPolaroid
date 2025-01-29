extends TextureRect

@export_category("Input Updater")
@export var input_listener: Node
@export var reactive = false
@export var disabled = false
@export var action_name: String
@export var keyboard: Texture
@export var keyboard_pressed: Texture
@export var keyboard_disabled: Texture
@export var xbox: Texture
@export var xbox_pressed: Texture
@export var xbox_disabled: Texture
@export var playstation: Texture
@export var playstation_pressed: Texture
@export var playstation_disabled: Texture

@export_category("Spatial UI")
@export var spatial = false
@export var camera_3d: Camera3D
@export var player_reference: Node3D
@export var object_3d : Node3D # The 3D node to follow
@export var visible_texture : Texture # Texture when distance is less than the visible distance
@export var interactable_distance : float = 3.0 # Distance at which texture changes
@export var visible_distance : float = 5.0 # Distance at which texture is visible

var input_type: String = "Keyboard" #"Keyboard" or "Gamepad"
var gamepad_type: String = "None" #"Xbox", "PlayStation", or "Unknown"
var distance: float
var distance_to_screen_center: float

func _process(delta):
	if not input_listener:
		print("Input listener not found: ", self.get_path())
		return
	
	input_type = input_listener.current_input_type
	gamepad_type = input_listener.gamepad_type
	
	if object_3d and camera_3d and player_reference and spatial:
		# Project 3D world position to 2D screen position
		var screen_position = camera_3d.unproject_position(object_3d.global_transform.origin)
		
		# Update the texture rect position
		position = screen_position - (size / 2)  # Center the rect on the projected position
		
		# Check if object is within the viewport and camera's view
		var viewport_rect = get_viewport_rect()
		var is_on_screen = viewport_rect.has_point(screen_position)
		var is_in_camera_view = camera_3d.is_position_behind(object_3d.global_transform.origin) == false
		var screen_center = Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2)
		distance_to_screen_center = screen_center.distance_to(screen_position)
		
		# Only show and update if object is on screen and in camera view
		if is_on_screen and is_in_camera_view:
			position = screen_position - (size / 2)
			visible = true
		if not is_in_camera_view:
			self.visible = false
		
		# Calculate distance between 3D objects
		distance = object_3d.global_transform.origin.distance_to(player_reference.global_transform.origin)
		
# Change texture based on distance
	if distance >= visible_distance and spatial:
		smooth_resize(Vector2(0,0), 0.12)
	elif distance_to_screen_center < 100 and distance <= interactable_distance or not spatial:
		if input_type == "Keyboard":
			if reactive == true and Input.is_action_pressed(action_name) and not disabled:
				self.texture = keyboard_pressed
			elif disabled:
				self.texture = keyboard_disabled
			else:
				self.texture = keyboard
		else:
			if gamepad_type == "PlayStation":
				if reactive == true and Input.is_action_pressed(action_name) and not disabled:
					self.texture = playstation_pressed
				elif disabled:
					self.texture = playstation_disabled
				else:
					self.texture = playstation
			else:
				if reactive == true and Input.is_action_pressed(action_name) and not disabled:
					self.texture = xbox_pressed
				elif disabled:
					self.texture = xbox_disabled
				else:
					self.texture = xbox
		smooth_resize(Vector2(40,40), 0.12)
	elif spatial:
		self.texture = visible_texture
		smooth_resize(Vector2(25,25), 0.2)

func smooth_resize(target_size: Vector2, duration: float = 0.5):
	var start_size = size
	var tween = create_tween()
	tween.tween_method(
		func(t): 
			size = start_size.lerp(target_size, t),
		0.0, 1.0, duration
	)
