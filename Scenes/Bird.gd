extends TextureFrame

const TIME_BETWEEN_MOVES = 0.8
const TIME_BETWEEN_FLAPS = TIME_BETWEEN_MOVES / 2
var lit = 1
var off = 0
var spriteMap = []
var timeSinceLastMove = 0
var timeSinceLastFlap = 0

export var currentPosition = 0
export var currentWingDirection = 'up'
export var currentFacing = 'right'

func _draw():
	for position in range(0, 10):
		for wingDirection in ['up', 'down']:
			for facing in ['left', 'right']:
				spriteMap[position][wingDirection][facing].set_opacity(off)
				
	spriteMap[currentPosition][currentWingDirection][currentFacing].set_opacity(lit)
	
	
func _process(delta):
	timeSinceLastMove += delta
	timeSinceLastFlap += delta
	
	if timeSinceLastFlap > TIME_BETWEEN_FLAPS:
		toggle_wings()
		timeSinceLastFlap = 0
		if randf() > 0.05:
			poop()
		update()
	
	if timeSinceLastMove > TIME_BETWEEN_MOVES:
		# if randf() > 0.80:
		#	toggle_facing()
		move()
		timeSinceLastMove = 0
		update()
	

func _ready():
	print("peanut butter birdy time!")
	spriteMap = []
	for position in range(0, 10):
		spriteMap.append({})
		for wingDirection in ['up', 'down']:
			spriteMap[position][wingDirection] = {}
			for facing in ['left', 'right']:
				load_sprite(facing, wingDirection, position)
	
	set_process(true)
	
func load_sprite(facing, wingDirection, position):
	var s = Sprite.new()
	var spriteName = "res://img/bird/%s/%s/%s.png" % [facing, wingDirection, position]
	print("Loading sprite: %s" % spriteName)
	s.set_texture(load(spriteName))
	# s.set_pos(Vector2(s.get_texture().get_width()/2,s.get_texture().get_height()/2))
	s.set_opacity(off)
	self.add_child(s)
	spriteMap[position][wingDirection][facing] = s
	
func toggle_wings():
	if currentWingDirection == 'up':
		currentWingDirection = 'down'
	else:
		currentWingDirection = 'up'

func toggle_facing():
	if currentFacing == 'left':
		currentFacing = 'right'
	else:
		currentFacing = 'left'

func move():
	if (currentFacing == 'left' and currentPosition == 0) or (currentFacing == 'right' and currentPosition == 9):
		toggle_facing()
	else:
		if currentFacing == 'left':
			currentPosition -= 1
		else:
			currentPosition += 1
			
func poop():
	print("pooping: ", currentPosition)
	var poopNode = get_tree().get_root().get_node("/root/Node2D/playField/Poop")
	poopNode.drop_deuce(currentPosition, 0.3)