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

#change input manually
var input = 0 #0=keyboard, 1=xbox, 2=playstation

func _ready():
	print("Listening for input type...")
	Input.set_use_accumulated_input(false)

func _input(event: InputEvent) -> void:
	
	if event is InputEventKey and event.pressed:
		if current_input_type != "Keyboard":
			current_input_type = "Keyboard"
			gamepad_type = "None"
			active_joypad_id = -1
			print("Input type changed to Keyboard")
	
	elif event is InputEventJoypadButton:
		if current_input_type != "Gamepad" or active_joypad_id != event.device:
			current_input_type = "Gamepad"
			active_joypad_id = event.device
			detect_gamepad_type(active_joypad_id)
			print("Input type changed to Gamepad: ", gamepad_type, " (ID: ", active_joypad_id, ")")
	
	#change input manually
	if Input.is_physical_key_pressed(KEY_PAGEUP):
		input+=1
		if input > 2: input = 0
		print(input)
	if Input.is_key_pressed(KEY_PAGEDOWN):
		input-=1
		if input < 0: input = 2
		print(input)
		
	#match input:
		#0: 
			#current_input_type = "Keyboard"
			#gamepad_type = "None"
		#1:
			#current_input_type = "Gamepad"
			#gamepad_type = "Xbox"
		#2:
			#current_input_type = "Gamepad"
			#gamepad_type = "PlayStation"

func detect_gamepad_type(joypad_id: int) -> void:
	var joypad_name = Input.get_joy_name(joypad_id)

	# Comprobar si el nombre coincide con los de Xbox
	for name in xbox_gamepad_names:
		if joypad_name.findn(name) != -1:
			gamepad_type = "Xbox"
			return

	# Comprobar si el nombre coincide con los de PlayStation
	for name in playstation_gamepad_names:
		if joypad_name.findn(name) != -1:
			gamepad_type = "PlayStation"
			return

	# Si no se reconoce, usar Xbox por defecto
	gamepad_type = "Xbox"
