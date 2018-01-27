
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var playerMovement=[[0,0,0,0,0,0],
			[0,0,4,4,0,0],
			[0,0,3,3,0,0],
			[0,1,2,1,2,0],
			[0,0,0,0,0,0]]
			
var playerPos = Vector2(3,1)
			
var keyMap = {}

func _process(delta):
	var targetPos
	#print("In process")
	
	if (Input.is_action_pressed("ui_left") && !keyMap.has("LEFT")):
		keyMap["LEFT"] = true
		targetPos = playerPos.x - 1
		if(_can_Move(targetPos,playerPos.y)):
			playerPos.x = targetPos
	elif (Input.is_action_pressed("ui_right") && !keyMap.has("RIGHT")):
		keyMap["RIGHT"] = true
		targetPos = playerPos.x + 1
		if(_can_Move(targetPos, playerPos.y)):
			playerPos.x = targetPos
	elif (Input.is_action_pressed("ui_up") && !keyMap.has("UP")):
		keyMap["UP"] = true
		targetPos = playerPos.y + 1
		if(_can_Move(playerPos.x, targetPos)):
			playerPos.y = targetPos
	elif (Input.is_action_pressed("ui_down") && !keyMap.has("DOWN")):
		keyMap["DOWN"] = true
		targetPos = playerPos.y - 1
		if(_can_Move(playerPos.x, targetPos)):
			playerPos.y = targetPos
			
			
	if !Input.is_action_pressed("ui_left"):
		keyMap.erase("LEFT")
	if !Input.is_action_pressed("ui_right"):
		keyMap.erase("RIGHT")
	if !Input.is_action_pressed("ui_up"):
		keyMap.erase("UP")
	if !Input.is_action_pressed("ui_down"):
		keyMap.erase("DOWN")

func _can_Move(targetX,targetY):
	print("target position: X: ")
	print( targetX)
	print( " Y: " )
	print( targetY)
	if(playerMovement[targetX][targetY] != 0):
		print("Movement Successful")
		return true
	else:
		print("Movement Failed")
		return false
	


func _ready():
	set_process(true)
	var x = 0
	var y = 0	
	
	for row in playerMovement:
		x = 0
		for col in row:
			#texture to playerMovement mapping
			#TODO
			if(col != 0):
				var s = Sprite.new()
				s.set_texture(load("res://icon.png"))
				s.set_pos(Vector2(x,y))
				self.add_child(s)
			x += 150
		y += 150
		
	
			
		
#for x in range(width):
   # matrix[x]=[]
   # for y in range(height):
    #    matrix[x][y]=0
	# Called every time the node is added to the scene.
	# Initialization here
	pass
