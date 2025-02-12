extends Node

var low_health = false
var timer = 0.0

func _process(delta: float) -> void:
	if low_health:
		if timer <= 0:
			timer = 1.6
			Input.start_joy_vibration(0,0.3,0,0.4)
		timer -= delta * 1
