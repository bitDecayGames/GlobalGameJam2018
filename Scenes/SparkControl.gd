const SPARK_IMAGE_DIRECTORY = "res://img/spark/"
const SPARK_OFF_IMAGE_OPACITY = 0.4

var sparkImgList = []
var spriteMap = []
var sparkMap = []

var canMakeSpark = true

func _ready():
	sparkImgList = list_files_in_directory(SPARK_IMAGE_DIRECTORY)
	print("sparkimg list  ", sparkImgList)
	load_the_sprite_map()
	set_process(true)

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
			
	for spark in sparkMap:
		if(spark.update_spark_pos(delta)):
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
		s.set_pos(Vector2(s.get_texture().get_width()/2,s.get_texture().get_height()/2))
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
			return (sparkCurrentPos + 1) < SPARK_MAX_POS_RIGHT
		else:
			return (sparkCurrentPos - 1) > SPARK_MAX_POS_LEFT
	
	func remove_this_spark():
		spriteMap[sparkCurrentPos].set_opacity(SPARK_OFF_IMAGE_OPACITY)
	
	func update_sprite():
		spriteMap[sparkPrevPos].set_opacity(SPARK_OFF_IMAGE_OPACITY)
		spriteMap[sparkCurrentPos].set_opacity(1)