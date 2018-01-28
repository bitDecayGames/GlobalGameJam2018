extends TextureFrame

const TIME_BETWEEN_MOVES = 0.8
const TIME_BETWEEN_FLAPS = TIME_BETWEEN_MOVES / 2
const TIME_BETWEEN_PECKS = TIME_BETWEEN_MOVES / 2
 
var lit = 1
var off = 0
var spriteMap = []
var timeSinceLastMove = 0
var timeSinceLastFlap = 0
var timeSinceLastPeck = 0
var peckCount = 0

export var currentPosition = 0
export var currentWingDirection = 'up'
export var currentFacing = 'right'
export var poopRate = 0.20
export var landRate = .5;
export var currentPerchState = '';
export var currentPerchPosition = ''

func _draw():
	for position in range(0, 10):
		for wingDirection in ['up', 'down']:
			for facing in ['left', 'right']:
				spriteMap[position][wingDirection][facing].set_opacity(off)

	for position in range(1, 7):
		for perchState in ['perching', 'pecking']:
			spriteMap[position][perchState].set_opacity(off)
		
	if is_perching():
		spriteMap[currentPerchPosition][currentPerchState].set_opacity(lit)
	else:		
		spriteMap[currentPosition][currentWingDirection][currentFacing].set_opacity(lit)
	
func _process(delta):
	
	if is_perching():
		timeSinceLastPeck += delta
		if timeSinceLastPeck > TIME_BETWEEN_PECKS:
			toggle_perching()
			if currentPerchState == 'pecking':
				peckCount += 1
				if peckCount > 3:
					peckCount = 0
					break_transformer()
					take_off()

			timeSinceLastPeck = 0
			
			update()
	else:
		timeSinceLastMove += delta
		timeSinceLastFlap += delta

		if timeSinceLastFlap > TIME_BETWEEN_FLAPS:
			toggle_wings()
			timeSinceLastFlap = 0
			update()
		
		if timeSinceLastMove > TIME_BETWEEN_MOVES:
			# if randf() > 0.80:
			#	toggle_facing()
			if randf() > 1 - poopRate:
				poop()
			
			if randf() > 1 - landRate:
				try_to_land()
				
			update()
			
			move()
			timeSinceLastMove = 0

func _ready():
	spriteMap = []
	for position in range(0, 10):
		spriteMap.append({})
		for wingDirection in ['up', 'down']:
			spriteMap[position][wingDirection] = {}
			for facing in ['left', 'right']:
				load_flying_sprite(facing, wingDirection, position)
	
	for position in range(1, 7):
		for perchState in ['perching', 'pecking']:
			load_perching_sprite(perchState, position)
	
	set_process(true)
	
func load_flying_sprite(facing, wingDirection, position):
	var s = Sprite.new()
	var spriteName = "res://img/bird/%s/%s/%s.png" % [facing, wingDirection, position]
	s.set_texture(load(spriteName))
	s.set_opacity(off)
	self.add_child(s)
	spriteMap[position][wingDirection][facing] = s

func load_perching_sprite(perchState,  position):
	var s = Sprite.new()
	var spriteName = "res://img/bird/%s/%s.png" % [perchState, position]
	s.set_texture(load(spriteName))
	s.set_opacity(off)
	self.add_child(s)
	spriteMap[position][perchState] = s

func toggle_perching():
	if currentPerchState == 'perching':
		currentPerchState = 'pecking'
	else:
		currentPerchState = 'perching'

func try_to_land():
	var flyingPosToLandingPos = {
		0: null,
		1: 2,
		2: 1,
		3: null,
		4: 4,
		5: 3,
		6: null,
		7: 6,
		8: 5,
		9: null,
	}
	
	var landingPos = flyingPosToLandingPos[currentPosition];
	if (currentFacing == 'left' and landingPos and landingPos % 2 == 0) or (currentFacing == 'right' and landingPos and landingPos % 2 == 1):
		landingPos = null
	if landingPos:
		currentPerchPosition = landingPos
		currentPerchState = 'perching'
		
func take_off():
	currentPerchState = null
	currentPerchPosition = null
	
func break_transformer():
	var perchToCol = {
		1: 2,
		2: 3,
		3: 5,
		4: 6,
		5: 8,
		6: 9
	}
	var globals = get_node("/root/global") 
	var map = globals.get("playerMovement")
	map[1][perchToCol[currentPerchPosition]] |= globals.get("transformerBlown")

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

func is_perching():
	return currentPerchState == 'perching' or currentPerchState == 'pecking'

func move():
	if (currentFacing == 'left' and currentPosition == 0) or (currentFacing == 'right' and currentPosition == 9):
		toggle_facing()
	else:
		if currentFacing == 'left':
			currentPosition -= 1
		else:
			currentPosition += 1
			
func poop():
	var poopNode = get_tree().get_root().get_node("/root/Node2D/playField/Poop")
	poopNode.drop_deuce(currentPosition, 0.3)