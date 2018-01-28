extends StreamPlayer

func _ready():
	pass
	set_process(true)

func _process(delta):
	if(not self.is_playing()):
		self.play()