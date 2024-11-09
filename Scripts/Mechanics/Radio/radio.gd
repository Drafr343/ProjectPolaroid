extends Node

var freq
var min = 1000
var max = 1200
@export var multiplier = 25

func _ready() -> void:
	freq = min


func _physics_process(delta):
	# Changes radio freq with input
	if Input.is_action_pressed("radio_right") and freq < max:
		freq += 1 * (delta * multiplier)
	elif Input.is_action_pressed("radio_left") and freq > min:
		freq -= 1 * (delta * multiplier)
