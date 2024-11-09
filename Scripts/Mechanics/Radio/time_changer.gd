extends Node

@export var radio: Node
@export var default_scene: Node3D
@export var alternative_scene: Node3D
@export var alt_freq = 1023
@export var def_freq = 1058
@export var sound_player: AudioStreamPlayer2D
@export var sound_reaching: AudioStream
@export var sound_reached: AudioStream
const max_timer = 1.3
const freq_tolerance = 1.2
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
		if radio.freq > def_freq - freq_tolerance and radio.freq < def_freq + freq_tolerance:
			if timer < max_timer: timer += 1.0 * delta
			play_sound()
		else:
			if timer > 0: timer -= 3 * delta
	else:
		if radio.freq > alt_freq - freq_tolerance and radio.freq < alt_freq + freq_tolerance:
			if timer < max_timer: timer += 1.0 * delta
			play_sound()
		else:
			if timer > 0: timer -= 3 * delta
	
	#Manejo de la variable alternative_time que indica en que escenario se encuentra actualmente
	if timer >= max_timer:
		alternative_time = !alternative_time
		sound_player.stream = sound_reached
		sound_player.play()
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

func play_sound():
	if !sound_player.playing:
		sound_player.stream = sound_reaching
		sound_player.play()
func enter(body: Node):
	if body.is_in_group("player"):
		onTrigger = true
		print("On Trigger")
func exit(body: Node):
	if body.is_in_group("player"):
		onTrigger = false
		print("Exited Trigger")
