extends Node

var freq
var min = 1000
var max = 1200
var searching = false
@export var multiplier = 25
@export_category("Audio")
@export var searchingFreq: AudioStreamPlayer2D
@export var soundEffect: Array[AudioStream]

func _ready() -> void:
	freq = 1100


func _physics_process(delta):
	# Changes radio freq with input
	if Input.is_action_pressed("radio_right") and freq < max:
		freq += Input.get_action_strength("radio_right") * (delta * multiplier)
		searching = true
	elif Input.is_action_pressed("radio_left") and freq > min:
		freq -= Input.get_action_strength("radio_left") * (delta * multiplier)
		searching = true
	else:
		searching = false
	
	if searching:
		if !searchingFreq.playing: 
			var rand_index:int = randi() % soundEffect.size()
			searchingFreq.stream = soundEffect[rand_index]
			searchingFreq.play()
	else:
		searchingFreq.stop()
	
