extends TextureFrame

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var delay = .5

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	pass

func _process(delta):
	delay -= delta
	if delay <= 0:
		self.set_hidden(true)