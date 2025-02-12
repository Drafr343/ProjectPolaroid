extends Node

@export var xbox_gamepad_names: Array[StringName] = [
	"Xbox", "XInput", "Microsoft"
]
@export var playstation_gamepad_names: Array[StringName] = [
	"PlayStation", "Sony", "PS"
]

var current_input_type: String = "Keyboard" # "Keyboard" or "Gamepad"
var gamepad_type: String = "None" # "Xbox", "PlayStation", or "Unknown"
var active_joypad_id: int = -1 # ID del mando que está generando input

# Change input manually (0 = keyboard, 1 = xbox, 2 = playstation)
var input = 0  

func _ready():
	print("Listening for input type...")
	Input.set_use_accumulated_input(false)

func _input(event: InputEvent) -> void:
	# Detectar teclado
	if event is InputEventKey and event.pressed:
		if current_input_type != "Keyboard":
			current_input_type = "Keyboard"
			gamepad_type = "None"
			active_joypad_id = -1
			print("Input type changed to Keyboard")
	
	# Detectar mando (botón presionado o joystick movido fuera de la zona muerta)
	elif event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.2):
		var new_gamepad_type = detect_gamepad_type(event.device)
		
		if current_input_type != "Gamepad" or gamepad_type != new_gamepad_type:
			current_input_type = "Gamepad"
			active_joypad_id = event.device
			gamepad_type = new_gamepad_type
			print("Input type changed to Gamepad: ", gamepad_type, " (ID: ", active_joypad_id, ")")

# Función corregida para detectar el tipo de mando y devolverlo
func detect_gamepad_type(joypad_id: int) -> String:
	var joypad_name = Input.get_joy_name(joypad_id)

	# Comprobar si el nombre coincide con Xbox
	for name in xbox_gamepad_names:
		if joypad_name.findn(name) != -1:
			return "Xbox"

	# Comprobar si el nombre coincide con PlayStation
	for name in playstation_gamepad_names:
		if joypad_name.findn(name) != -1:
			return "PlayStation"

	# Si no se reconoce, usar Xbox por defecto
	return "Xbox"
