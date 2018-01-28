extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var soundID = 0

func _pressed():
	get_tree().change_scene("res://Scenes/GameOver.tscn")

func _ready():
    set_process_input(true)

func _input(event):
	if self.is_hovered():
		var samplePlayer = get_tree().get_root().get_node("/root/dummyNode_titleScreen/SamplePlayer")
		if soundID == 0 || !samplePlayer.is_voice_active(soundID):
			soundID = samplePlayer.play("hovermenu")
