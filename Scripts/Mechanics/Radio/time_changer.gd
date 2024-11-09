extends Node

@export var radio: Node
@export var default_scene: Node3D
@export var alternative_scene: Node3D
@export var alt_freq = 1023
@export var def_freq = 1058
const max_timer = 1.5
var onTrigger = false
var timer = 0
var alternative_time = false

func _ready() -> void:
	alternative_scene.set_process(false)
	alternative_scene.set_physics_process(false)
	alternative_scene.set_visible(false)


func _physics_process(delta):
	if onTrigger:
		print("Current freq: %.2f\nTimer: %.2f\nAlt time: %s" % [radio.freq, timer, alternative_time])
		time_anomaly(delta)
	else:
		timer = 0

func time_anomaly(delta):
	#Manejo del timer, si se mantiene la frecuencia el timer incrementa, caso contrario decrese
	if alternative_time:
		if radio.freq > def_freq - 1.5 and radio.freq < def_freq + 1.5:
			if timer < max_timer: timer += 1.0 * delta
		else:
			if timer > 0: timer -= 3 * delta
	else:
		if radio.freq > alt_freq - 1.5 and radio.freq < alt_freq + 1.5:
			if timer < max_timer: timer += 1.0 * delta
		else:
			if timer > 0: timer -= 3 * delta
	
	#Manejo de la variable alternative_time que indica en que escenario se encuentra actualmente
	if timer >= max_timer:
		alternative_time = !alternative_time
		timer = 0
	
	#Cambio de escenografia
	if alternative_time:
		alternative_scene.set_process(true)
		alternative_scene.set_physics_process(true)
		alternative_scene.set_visible(true)
		default_scene.set_process(false)
		default_scene.set_physics_process(false)
		default_scene.set_visible(false)
	else:
		alternative_scene.set_process(false)
		alternative_scene.set_physics_process(false)
		alternative_scene.set_visible(false)
		default_scene.set_process(true)
		default_scene.set_physics_process(true)
		default_scene.set_visible(true)

func enter(body: Node):
	if body.is_in_group("player"):
		onTrigger = true
		print("On Trigger")
func exit(body: Node):
	if body.is_in_group("player"):
		onTrigger = false
		print("Exited Trigger")
