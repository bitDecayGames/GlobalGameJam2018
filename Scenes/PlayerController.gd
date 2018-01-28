# Sound
var soundMaker
var playWalkNoiseOne = true

# Board bit masks
var moveableSpace = 1 << 0
var playerPresent = 1 << 1
var extinguisherSpawned = 1 << 2
var transformerSpawned = 1 << 3
var onFire = 1 << 4
var birdPoop = 1 << 5
var transformerBlown = 1 << 6


var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var stay = Vector2(0, 0)

var playerMovement=[[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,1,1,0,1,1,0,1,1,0,0],
					[0,0,1,1,0,1,1,0,1,1,0,0],
					[0,0,1,1,0,1,1,0,1,1,0,0],
					[0,1,1,1,1,1,1,1,1,1,1,0],
					[0,0,0,0,0,0,0,0,0,0,0,0]]
					
var groundRow = 4
var topOfPole = 1

var spriteMap=[]

var lit = 1
var low = 0.08
var off = 0

var left_action = "ui_left"
var right_action = "ui_right"
var up_action = "ui_up"
var down_action = "ui_down"
var action_action = "ui_select"

# Player state strings
var noItem = "player"

var transformer = Sprite.new()
var transformerItem = "transformer"

var extinguisher = Sprite.new()
var extinguisherItem = "extinguisher"

var playerPos = Vector2(3, groundRow)
var playerState = noItem;

var keyMap = {}

func _process(delta):
	var targetDir = stay
	var nextMove = stay
	
	if (Input.is_action_pressed(left_action) && !keyMap.has(left_action)):
		keyMap[left_action] = true
		targetDir = left
	elif (Input.is_action_pressed(right_action) && !keyMap.has(right_action)):
		keyMap[right_action] = true
		targetDir = right
	elif (Input.is_action_pressed(up_action) && !keyMap.has(up_action)):
		keyMap[up_action] = true
		targetDir = up
	elif (Input.is_action_pressed(down_action) && !keyMap.has(down_action)):
		keyMap[down_action] = true
		targetDir = down

	if(_can_Move(playerPos, targetDir)):
		nextMove = targetDir
		if targetDir != stay:
			play_walk_sound()

	# Remove mask from leaving position
	playerMovement[playerPos.y][playerPos.x] ^= playerPresent
	var previousPos = playerPos
	
	playerPos += nextMove
#	# Add mask to new position
	playerMovement[playerPos.y][playerPos.x] |= playerPresent
			
	# interactions
	if playerMovement[playerPos.y][playerPos.x] & extinguisherSpawned:
		playerState = extinguisherItem
		#playerMovement[playerPos.y][playerPos.x] ^= extinguisherSpawned
		extinguisher.set_opacity(off)
	elif playerMovement[playerPos.y][playerPos.x] & transformerSpawned:
		playerState = transformerItem
		transformer.set_opacity(off)
	elif playerMovement[playerPos.y][playerPos.x] & onFire:
		print("Fire")

	if nextMove != stay && previousPos.y == topOfPole:
			extinguisher.set_opacity(lit)
			transformer.set_opacity(lit)
			playerState = noItem

	update_sprites()
#	
	for action in keyMap:
		if !Input.is_action_pressed(action):
			keyMap.erase(action)

func _can_Move(currentPos,moveDir):
	var destPos = Vector2(currentPos.x, currentPos.y) + moveDir
	if(playerMovement[destPos.y][destPos.x] != 0):
		return true
	else:
		return false
	

func play_walk_sound():
	if playWalkNoiseOne:
		soundMaker.play("walk1")
	else:
		soundMaker.play("walk2")
	playWalkNoiseOne = not playWalkNoiseOne

func update_sprites():
	for row in range(playerMovement.size()):
		for col in range(playerMovement[row].size()):
			if playerPos.x == col && playerPos.y == row:
				for state in spriteMap[row][col]:
					if state == playerState:
						spriteMap[playerPos.y][playerPos.x][state].set_opacity(lit)
					else:
						spriteMap[playerPos.y][playerPos.x][state].set_opacity(off)
			else:
				for state in spriteMap[row][col]:
					spriteMap[row][col][state].set_opacity(off)

func _ready():
	set_process(true)
	
	soundMaker = get_tree().get_root().get_node("/root/TextureFrame/SamplePlayer")
	
	var backgroundLCDs = Sprite.new()
	backgroundLCDs.set_texture(load("res://img/blankCells.png"))
	backgroundLCDs.set_pos(Vector2(backgroundLCDs.get_texture().get_width()/2,backgroundLCDs.get_texture().get_height()/2))
	backgroundLCDs.set_opacity(low)
	self.add_child(backgroundLCDs)
	
	
	extinguisher.set_texture(load("res://img/fireExtinguisher.png"))
	extinguisher.set_pos(Vector2(extinguisher.get_texture().get_width()/2, extinguisher.get_texture().get_height()/2))
	extinguisher.set_opacity(lit)
	self.add_child(extinguisher)
	
	playerMovement[4][1] |= extinguisherSpawned
	
	transformer.set_texture(load("res://img/electricTransformer.png"))
	transformer.set_pos(Vector2(transformer.get_texture().get_width()/2, transformer.get_texture().get_height()/2))
	transformer.set_opacity(lit)
	self.add_child(transformer)
	
	# set our item spawns
	playerMovement[groundRow][1] |= extinguisherSpawned
	playerMovement[groundRow][10] |= transformerSpawned
	
	# set our player spawn
	playerMovement[playerPos.y][playerPos.x] |= playerPresent
	
	print_board()
	
	spriteMap = []
	for row in range(playerMovement.size()):
		spriteMap.append([])
		for col in range(playerMovement[row].size()):
			spriteMap[row].append({})
			if(playerMovement[row][col] != 0):
				# Load player sprite
				load_sprite("player", row, col)
				
#				# Load player w/ extinguisher sprites
				load_sprite("extinguisher", row, col)
				
				# Load player w/ transformer sprites
				load_sprite("transformer", row, col)

func load_sprite(stateString, row, col):
	var s = Sprite.new()
	var spriteName = "res://img/%s/%s/%s.png" % [stateString, row, col]
	print("Loading sprite: %s" % spriteName)
	s.set_texture(load(spriteName))
	s.set_pos(Vector2(s.get_texture().get_width()/2,s.get_texture().get_height()/2))
	s.set_opacity(off)
	self.add_child(s)
	spriteMap[row][col][stateString] = s
	
func print_board():
	for row in playerMovement:
		print(row)