extends TextureRect

@export var rotation_speed : float = 200.0 # deg per second
@export var action_name: String

func _ready() -> void:
	self.pivot_offset = self.size / 2

func _process(delta: float) -> void:
	if Input.is_action_pressed(action_name):
		self.rotation_degrees += rotation_speed * delta
		self.visible = true
	else:
		self.visible = false
		self.rotation_degrees = 0
