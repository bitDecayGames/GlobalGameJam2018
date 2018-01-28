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

var transformerList = []

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
		print_board()
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
	if playerMovement[playerPos.y][playerPos.x] & extinguisherSpawned && playerState != extinguisherItem:
		playerState = extinguisherItem
		# soundMaker.play("pickup")
		#playerMovement[playerPos.y][playerPos.x] ^= extinguisherSpawned
		extinguisher.set_opacity(off)
	elif playerMovement[playerPos.y][playerPos.x] & transformerSpawned && playerState != transformerItem:
		playerState = transformerItem
		# soundMaker.play("pickup")
		transformer.set_opacity(off)
	elif playerMovement[playerPos.y][playerPos.x] & onFire:
		print("Fire", false)

	if nextMove == up && playerPos.y == topOfPole && playerState == transformerItem:
		# soundMaker.play("plugin", false)
		pass
	if nextMove == up && playerPos.y == topOfPole && playerState == extinguisherItem:
		# soundMaker.play("extinguish", false)
		pass

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
#		soundMaker.play("walk1")
		pass
	else:
#		soundMaker.play("walk2")
		pass
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
					
	for trans in transformerList:
		trans._update()

func _ready():
	set_process(true)
	
	# soundMaker = get_tree().get_root().get_node("/root/Node2D/SamplePlayer")
	
	var backgroundLCDs = Sprite.new()
	backgroundLCDs.set_texture(load("res://img/blankCells.png"))
	backgroundLCDs.set_opacity(low)
	self.add_child(backgroundLCDs)
	
	
	extinguisher.set_texture(load("res://img/fireExtinguisher.png"))
	extinguisher.set_opacity(lit)
	self.add_child(extinguisher)
	
	playerMovement[4][1] |= extinguisherSpawned
	
	transformer.set_texture(load("res://img/electricTransformer.png"))
	transformer.set_opacity(lit)
	self.add_child(transformer)
	
	# set our item spawns
	playerMovement[groundRow][1] |= extinguisherSpawned
	playerMovement[groundRow][10] |= transformerSpawned
	
	# set our player spawn
	playerMovement[playerPos.y][playerPos.x] |= playerPresent
	
	transformerList.append(transformerBox.new(Vector2(2,1),1,playerMovement, transformerBlown))
	transformerList.append(transformerBox.new(Vector2(3,1),2,playerMovement, transformerBlown))
	transformerList.append(transformerBox.new(Vector2(5,1),3,playerMovement, transformerBlown))
	transformerList.append(transformerBox.new(Vector2(6,1),4,playerMovement, transformerBlown))
	transformerList.append(transformerBox.new(Vector2(8,1),5,playerMovement, transformerBlown))
	transformerList.append(transformerBox.new(Vector2(9,1),6,playerMovement, transformerBlown))
	
	playerMovement[1][3] |= transformerBlown
	playerMovement[1][5] |= transformerBlown
	playerMovement[1][6] |= transformerBlown
	
	for trans in transformerList:
		for sprite in trans.spriteGetter():
			self.add_child(sprite)
		
	
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
	s.set_opacity(off)
	self.add_child(s)
	spriteMap[row][col][stateString] = s
	
func print_board():
	for row in playerMovement:
		print(row)
	print()
		
class transformerBox:
	var pos
	var brokenSprite
	var fixedSprite
	var playerMap
	var blownTransformer
	
	func _init(position, transformerNum, playerMovement, transformerBlown):
		pos = position
		blownTransformer = transformerBlown
		playerMap = playerMovement
		brokenSprite = Sprite.new()
		var spriteName = "res://img/brokenTrans/%s.png" % [transformerNum]
		brokenSprite.set_texture(load(spriteName))
		brokenSprite.set_opacity(0)
		
		fixedSprite = Sprite.new()
		var spriteName = "res://img/fixedTrans/%s.png" % [transformerNum]
		fixedSprite.set_texture(load(spriteName))
		fixedSprite.set_opacity(1)
		
		
		
	func _update():
		#check player map for state
		#set sprite accordingly
		if((playerMap[pos.y][pos.x] & blownTransformer) != 0):
			self.brokenSprite.set_opacity(1)
			self.fixedSprite.set_opacity(0)
		else:
			self.brokenSprite.set_opacity(0)
			self.fixedSprite.set_opacity(1)
	
	func spriteGetter():
		return [fixedSprite,brokenSprite]