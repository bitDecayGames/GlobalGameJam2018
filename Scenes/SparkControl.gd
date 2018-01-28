const SPARK_IMAGE_DIRECTORY = "res://img/spark/"
const SPARK_OFF_IMAGE_OPACITY = 0.4
const TIME_UNTIL_NEXT_SPARK_SPAWN = 10



var sparkImgList = []
var spriteMap = []
var sparkMap = []

var soundMaker
var fireStream

var sparkSpawnTimer = 0
var canMakeSpark = true
var playerMovement

func _ready():
	
	soundMaker = get_tree().get_root().get_node("/root/Node2D/SamplePlayer")
	fireStream = get_tree().get_root().get_node("/root/Node2D/StreamPlayerFire")
	playerMovement = get_node("/root/global").get("playerMovement")
	sparkImgList = list_files_in_directory(SPARK_IMAGE_DIRECTORY)
	print("sparkimg list  ", sparkImgList)
	load_the_sprite_map()
	create_spark()
	set_process(true)
	
func _getPlayerMapForPos(sparkPos):
	if(sparkPos == 2):
		return 2
	elif(sparkPos == 3):
		return 3
	elif(sparkPos == 7 ):
		return 5
	elif(sparkPos == 8):
		return 6
	elif(sparkPos == 12):
		return 8
	elif(sparkPos == 13):
		return 9
	else:
		return -1

func _process(delta):
	#DEBUG THINGS
	if(Input.is_action_pressed("makeSpark") && canMakeSpark):
		canMakeSpark = false
		create_spark()
	if(Input.is_action_pressed("getSparkMapStats")):
		print("SparkMapSize: ", sparkMap.size())
		for spark in sparkMap:
			print("\nSpark's pos: ", spark.sparkCurrentPos)
			print("\nSpark started left? : ", spark.sparkStartingLeft)
			print("\nSpark time to move? : ", spark.sparkTimeUntilMove)
			#DEBUG THINGS
			
	sparkSpawnTimer += delta
	if(sparkSpawnTimer >= TIME_UNTIL_NEXT_SPARK_SPAWN):
		sparkSpawnTimer = 0
		create_spark()
	
	var onFire = 1 << 4
	var transformerBlown = 1 << 6
	
	
	for spark in sparkMap:
		spriteMap[spark.sparkCurrentPos].set_opacity(1)
		if(spark.update_spark_pos(delta)):
			spark.remove_this_spark()
			sparkMap.erase(spark)
			# time is up and we can't move, we are at the end
			var value = get_tree().get_root().get_node("/root/Node2D/playField/Score").get("value")
			value += 1
			soundMaker.play("elecvictory")
			get_tree().get_root().get_node("/root/Node2D/playField/Score").set("value", value)
		else:
			var playerCol = _getPlayerMapForPos(spark.sparkCurrentPos)
			if(playerCol != -1 && playerMovement[1][playerCol] & transformerBlown):
				if !(playerMovement[1][playerCol] & onFire):
					fireStream.stop()
					fireStream.play()
				playerMovement[1][playerCol] |= onFire
				spark.remove_this_spark()
				sparkMap.erase(spark)
		
	if(!Input.is_action_pressed("makeSpark")):
		canMakeSpark = true

func load_the_sprite_map():
	spriteMap = []
	
	for i in range(sparkImgList.size()):
		spriteMap.append([])
		var s = Sprite.new()
		s.set_texture(load(sparkImgList[i]))
		s.set_opacity(SPARK_OFF_IMAGE_OPACITY)
		self.add_child(s)
		spriteMap[i] = s

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(path + file)
	
	dir.list_dir_end()
	files.sort()
	return files

func create_spark():
	var newSpark = Spark.new(spriteMap)
	sparkMap.append(newSpark)

class Spark:
	const SPARK_MAX_POS_LEFT = 0
	const SPARK_MAX_POS_RIGHT = 15
	const SPARK_MAX_TIME_UNTIL_MOVE = 1
	
	var sparkStartingLeft
	var sparkCurrentPos
	var sparkPrevPos
	var sparkTimeUntilMove
	var spriteMap
	
	func _init(spriteMap):
		self.spriteMap = spriteMap
		sparkTimeUntilMove = SPARK_MAX_TIME_UNTIL_MOVE
		sparkStartingLeft = spark_starts_on_left()
		if sparkStartingLeft:
			sparkCurrentPos = SPARK_MAX_POS_LEFT
		else:
			sparkCurrentPos = SPARK_MAX_POS_RIGHT
		spriteMap[sparkCurrentPos].set_opacity(1)
	
	func spark_starts_on_left():
		var zeroOrOne = randf()
		var isLeft = false
		if(zeroOrOne >= 0.5):
			isLeft = true
		return isLeft
	
	func update_spark_pos(delta):
		sparkTimeUntilMove -= delta
		if(sparkTimeUntilMove <= 0 && can_move_spark()):
			if(sparkStartingLeft):
				sparkPrevPos = sparkCurrentPos
				sparkCurrentPos += 1
				update_sprite()
				sparkTimeUntilMove = SPARK_MAX_TIME_UNTIL_MOVE
			else:
				sparkPrevPos = sparkCurrentPos
				sparkCurrentPos -= 1
				update_sprite()
				sparkTimeUntilMove = SPARK_MAX_TIME_UNTIL_MOVE
		elif(sparkTimeUntilMove <= 0):
			return true
	
	func can_move_spark():
		if(sparkStartingLeft):
			return (sparkCurrentPos + 1) <= SPARK_MAX_POS_RIGHT
		else:
			return (sparkCurrentPos - 1) >= SPARK_MAX_POS_LEFT
	
	func remove_this_spark():
		spriteMap[sparkCurrentPos].set_opacity(SPARK_OFF_IMAGE_OPACITY)
	
	func update_sprite():
		spriteMap[sparkPrevPos].set_opacity(SPARK_OFF_IMAGE_OPACITY)
		spriteMap[sparkCurrentPos].set_opacity(1)