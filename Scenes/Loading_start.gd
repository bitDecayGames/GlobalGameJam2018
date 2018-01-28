extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var timeLeft = .5

func _ready():
    set_process(true)

func _process(delta):
	print("delta: ")
	print(delta)
	timeLeft -= delta
	if timeLeft <= 0:
		get_tree().change_scene("res://Scenes/newGame.tscn")