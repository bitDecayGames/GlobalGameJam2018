extends VideoPlayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	self.play()
	set_process(true)
	pass

func _process(delta):
	if !self.is_playing():
		self.play()