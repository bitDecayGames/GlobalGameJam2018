extends Node2D

var lit = 1
var low = 0.08
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var spriteToBlink
var blinkingTimer

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	pass

func _process(delta):
	pass

func die(playerSpriteToBlink):
	get_tree().set_pause(true)
	print("paus has happened")
	spriteToBlink = playerSpriteToBlink
	
	var t = Timer.new()
	t.set_wait_time(3)
	t.set_one_shot(true)
	t.connect("timeout", self, "unpauseTheWorld")
	add_child(t)
	t.start()
	
	print(spriteToBlink)
	var untilBlink = Timer.new()
	untilBlink.set_wait_time(0.5)
	untilBlink.connect("timeout", self, "blinkSprite")
	blinkingTimer = untilBlink
	add_child(untilBlink)
	untilBlink.start()

func blinkSprite():
	if(spriteToBlink.get_opacity() == 1):
		spriteToBlink.set_opacity(low)
	else:
		spriteToBlink.set_opacity(lit)

func unpauseTheWorld():
	print("We Paus the WORLD!!")
	var playField = get_tree().get_root().get_node("/root/Node2D/playField")
	playField.resetPlayer()
	blinkingTimer.stop()
	spriteToBlink.set_opacity(low)
	get_tree().set_pause(false)