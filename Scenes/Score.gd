extends Control 

export var value = 123

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func _draw():	
	if value > 9999:
		value = 9999
	var s = String(value)
	var thousands = get_node("DigitThousands")
	var hundreds = get_node("DigitHundreds")
	var tens = get_node("DigitTens")
	var ones = get_node("DigitOnes")
	thousands.value = null
	hundreds.value = null
	tens.value = null
	ones.value = null
	if s.length() == 0:
		ones.value = 0
	elif s.length() == 1:
		ones.value = int(s[0])
	elif s.length() == 2:
		tens.value = int(s[0])
		ones.value = int(s[1])
	elif s.length() == 3:		
		hundreds.value = int(s[0])
		tens.value = int(s[1])
		ones.value = int(s[2])
	elif s.length() == 4:
		thousands.value = int(s[0])
		hundreds.value = int(s[1])
		tens.value = int(s[2])
		ones.value = int(s[3])
	
	
	
	