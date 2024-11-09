extends Node2D

var score = 5
var new_score

func add_to_score(points):
	# new_score is accidentally re-declared
	# with local scope in this indented code block
	var new_score = score + points

func _ready():
	add_to_score(1)
	# new_score has not been set
	print(new_score) # prints null
#puto el adalberto traga pito come winie de prro
