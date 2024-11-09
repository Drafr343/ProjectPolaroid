extends Node

@export var radio: Node
@export var default_scene: Node3D
@export var alternative_scene: Node3D
@export var time_freq = 1105
var timer = 0

func _ready() -> void:
	pass


func _physics_process(delta):
	print("Current freq: %.2f\nTimer: %.2f" % [radio.freq, timer])
	if radio.freq > time_freq - 1.5 and radio.freq < time_freq + 1.5:
		if timer < 3.5: timer += 1.0 * delta
	else:
		if timer > 0: timer -= 3 * delta
