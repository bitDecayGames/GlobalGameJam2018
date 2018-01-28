extends Node

var off = 0
var lit = 1

var poopMatrix = []

var activePoops = []

class SingleTurd:
	var depth = 0
	var hangTime = .2
	var timeLeft
	var column
	
	var sprites
	var map
	var turdMask
	
	func _init(hang, column, sprites, playerMap, turdMask):
		self.hangTime = hang
		self.timeLeft = hang
		self.column = column
		self.sprites = sprites
		self.map = playerMap
		self.turdMask = turdMask
		update_sprites()
		set_poop_flag()
		
	func update(delta):
		self.timeLeft -= delta
		if self.timeLeft <= 0:
			# move
			self.timeLeft = self.hangTime
			cleanup_poop_flag()
			self.depth+=1
			
			self.update_sprites()
			if self.depth >= 9:
				return true
			else:
				set_poop_flag()
				for row in self.map:
					print(row)
				print("")
		self.update_sprites()
		return false
		
	func cleanup_poop_flag():
		var row = getMapForDepth(self.depth)
		if row == -1:
			return
		self.map[row][column] ^= self.turdMask
		
	func set_poop_flag():
		var row = getMapForDepth(self.depth)
		if row == -1:
			return
		self.map[row][column] |= self.turdMask
		
	func update_sprites():
		for row in range(10):
			if row == self.depth:
				sprites[row][self.column].set_opacity(1)
			else:
				sprites[row][self.column].set_opacity(0)
				
	func getMapForDepth(depth):
		# 3 depth = 2 map
		# 5 depth = 3 map
		# 7 depth = 4 map
		if depth == 2:
			return 2
		elif depth == 4:
			return 3
		elif depth == 6:
			return 4
		else:
			return -1
	

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	set_process(true)
	for col in range(10):
		poopMatrix.append([])
		for row in range(10):
			poopMatrix[col].append(load_sprite("poop", row, col))
		
func load_sprite(stateString, row, col):
	var s = Sprite.new()
	var spriteName = "res://img/%s/%s/%s.png" % [stateString, row, col]
	print("Loading sprite: %s" % spriteName)
	s.set_texture(load(spriteName))
	s.set_centered(false)
	s.set_opacity(off)
	self.add_child(s)
	return s
	
func drop_deuce(column, hangTime):
	var map = get_node("/root/global").get("playerMovement")
	var mask = get_node("/root/global").get("birdPoop")
	activePoops.append(SingleTurd.new(hangTime, column, poopMatrix, map, mask))
		
func _process(delta):
	var poopCount = activePoops.size()
	for i in range(poopCount-1, -1, -1):
		if activePoops[i].update(delta):
			activePoops.remove(i)
		
