extends Node

export var value = 6

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)

func _draw():
	var segments = []
	if value == 0:
		segments = ['A', 'B', 'C', 'D', 'E', 'F'] 
	elif value == 1:
		segments = ['E', 'F'] 
	elif value == 2:
		segments = ['A', 'B', 'D', 'E', 'G'] 
	elif value == 3:
		segments = ['A', 'B', 'C', 'D', 'G'] 
	elif value == 4:
		segments = ['B', 'C', 'F', 'G'] 
	elif value == 5:
		segments = ['A', 'C', 'D', 'F', 'G'] 
	elif value == 6:
		segments = ['A', 'C', 'D', 'E', 'F', 'G'] 
	elif value == 7:
		segments = ['A', 'B', 'C'] 
	elif value == 8:
		segments = ['A', 'B', 'C', 'D', 'E', 'F', 'G'] 
	elif value == 9:
		segments = ['A', 'B', 'C', 'D', 'F', 'G'] 

	for letter in ['A', 'B', 'C', 'D', 'E', 'F', 'G']:
		hide_segment(letter)
		
	for letter in segments:
		show_segment(letter)

func _process(delta):
	update()
		
func get_segment(letter):
		var sprite = "Segment" + letter
		return get_node(sprite)
		
func show_segment(letter):
		get_segment(letter).show()
		
func hide_segment(letter):
		get_segment(letter).hide()
		
func set_value(v):
	value = value

func get_value():
	return value