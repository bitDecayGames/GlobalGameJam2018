
var playerMovement=[[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,1,1,0,1,1,0,1,1,0,0],
					[0,0,1,1,0,1,1,0,1,1,0,0],
					[0,1,1,1,1,1,1,1,1,1,1,0],
					[0,0,0,0,0,0,0,0,0,0,0,0]]

var spriteMap=[]

var lit = 1
var off = 0.08

var left_action = "ui_left"
var right_action = "ui_right"
var up_action = "ui_up"
var down_action = "ui_down"
var action_action = "ui_select"

# Player state strings
var noItem = "player"
var transformerItem = "transformer"
var extinguisherItem = "extinguisher"

export var playerPos = Vector2(1, 3)
var playerState = noItem;



var keyMap = {}

func _process(delta):
	var targetPos
	if (Input.is_action_pressed(left_action) && !keyMap.has(left_action)):
		keyMap[left_action] = true
		targetPos = playerPos.x - 1
		if(_can_Move(targetPos,playerPos.y)):
			playerPos.x = targetPos
	elif (Input.is_action_pressed(right_action) && !keyMap.has(right_action)):
		keyMap[right_action] = true
		targetPos = playerPos.x + 1
		if(_can_Move(targetPos, playerPos.y)):
			playerPos.x = targetPos
	elif (Input.is_action_pressed(up_action) && !keyMap.has(up_action)):
		keyMap[up_action] = true
		targetPos = playerPos.y - 1
		if(_can_Move(playerPos.x, targetPos)):
			playerPos.y = targetPos
	elif (Input.is_action_pressed(down_action) && !keyMap.has(down_action)):
		keyMap[down_action] = true
		targetPos = playerPos.y + 1
		if(_can_Move(playerPos.x, targetPos)):
			playerPos.y = targetPos
			
	for action in keyMap:
		if !Input.is_action_pressed(action):
			keyMap.erase(action)
			
	update_sprites()

func _can_Move(targetX,targetY):
	if(playerMovement[targetY][targetX] != 0):
		return true
	else:
		return false
	

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
	
	spriteMap = []
	for row in range(playerMovement.size()):
		spriteMap.append([])
		for col in range(playerMovement[row].size()):
			spriteMap[row].append({})
			#texture to playerMovement mapping
			#TODO
			if(playerMovement[row][col] != 0):
				# Load player sprite
				load_sprite("player", row, col)
								
				
				# Load transformer sprites
				load_sprite("player", row, col)

func load_sprite(stateString, row, col):
	var s = Sprite.new()
	var spriteName = "res://img/%s/%s/%s.png" % [stateString, row, col]
	s.set_texture(load(spriteName))
	s.set_pos(Vector2(s.get_texture().get_width()/2,s.get_texture().get_height()/2))
	s.set_opacity(off)
	self.add_child(s)
	spriteMap[row][col][stateString] = s