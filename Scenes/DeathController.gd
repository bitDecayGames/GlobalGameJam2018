extends Node2D

var lit = 1
var low = 0.08
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var spritesToBlink
var blinkingTimer

var blinkState = 0

var soundMaker
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	soundMaker = get_tree().get_root().get_node("/root/Node2D/SamplePlayer")
	set_process(true)
	pass

func _process(delta):
	pass

func die(playerSpritesToBlink):
	get_tree().set_pause(true)
	spritesToBlink = playerSpritesToBlink
	
	var t = Timer.new()
	t.set_wait_time(3)
	t.set_one_shot(true)
	t.connect("timeout", self, "unpauseTheWorld")
	add_child(t)
	t.start()
	
	var untilBlink = Timer.new()
	untilBlink.set_wait_time(0.5)
	untilBlink.connect("timeout", self, "blinkSprites")
	blinkingTimer = untilBlink
	add_child(untilBlink)
	untilBlink.start()

func blinkSprites():
	for sprite in spritesToBlink:
		sprite.set_opacity(blinkState)
	if blinkState == 0:
		blinkState = 1
	else:
		blinkState = 0

func unpauseTheWorld():
	print("We Paus the WORLD!!")
	var playField = get_tree().get_root().get_node("/root/Node2D/playField")
	playField.resetPlayer()
	blinkingTimer.stop()
	for sprite in spritesToBlink:
		sprite.set_opacity(low)
	get_tree().set_pause(false)
