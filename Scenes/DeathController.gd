extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var soundMaker
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	soundMaker = get_tree().get_root().get_node("/root/Node2D/SamplePlayer")
	set_process(true)
	pass

func _process(delta):
	pass

func die(playerSpriteToBlink):
	get_tree().set_pause(true)
	print("paus has happened")
	
	var t = Timer.new()
	t.set_wait_time(3)
	t.set_one_shot(true)
	t.connect("timeout", self, "unpauseTheWorld")
	add_child(t)
	t.start()
	

func blinkSprite(playerSpriteToBlink):
	pass

func unpauseTheWorld():
	print("We Paus the WORLD!!")
	var playField = get_tree().get_root().get_node("/root/Node2D/playField")
	playField.resetPlayer()
	get_tree().set_pause(false)