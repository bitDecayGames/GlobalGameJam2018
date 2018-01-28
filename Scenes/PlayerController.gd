# Sound
var soundMaker
var playWalkNoiseOne = true
var fireSound
var score = 0000

var lives = 3
var life1
var life2
var life3

var fireStream

# Board bit masks
var moveableSpace = 1 << 0
var playerPresent = 1 << 1
var extinguisherSpawned = 1 << 2
var transformerSpawned = 1 << 3
var onFire = 1 << 4
var birdPoop = 1 << 5
var transformerBlown = 1 << 6

var difficultyMod = 1.0
var difficultyIncrease = .01
var timeLightningHit = 0

var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var stay = Vector2(0, 0)

var playerMovement

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
var playerState = noItem
var scoreControl

var gameOver

var transformerDeath = false
const TRANSFORMER_DEATH_SPRITE = ""
const LIGHTNING_IMAGE_DIRECTORY = "res://img/lightning/"

const FLAMBE_IMAGE_DIRECTORY = "res://img/flambe/"
var fireDeath = false
var fireDeathSpriteList = []
var lightningSpriteList = []
var lightningToTransformer = { 0:2, 1:3, 2:5, 3:6, 4:8, 5:8 }
var poopDeath = false

var keyMap = {}

func _process(delta):
  transformerDeathCheck()
  poopDeathCheck()
  checkDeath()

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
# # Add mask to new position
  playerMovement[playerPos.y][playerPos.x] |= playerPresent

  # interactions
  if playerMovement[playerPos.y][playerPos.x] & extinguisherSpawned && playerState != extinguisherItem:
    if(playerState == transformerItem):
      transformer.set_opacity(lit)
    playerState = extinguisherItem
    soundMaker.play("pickup", false)
    #playerMovement[playerPos.y][playerPos.x] ^= extinguisherSpawned
    extinguisher.set_opacity(off)
  elif playerMovement[playerPos.y][playerPos.x] & transformerSpawned && playerState != transformerItem:
    if(playerState == extinguisherItem):
      extinguisher.set_opacity(lit)
    playerState = transformerItem
    soundMaker.play("pickup", false)
    transformer.set_opacity(off)
  

  if nextMove == up && playerPos.y == topOfPole && playerState == transformerItem:
    soundMaker.play("plugin", false)
    if(playerMovement[playerPos.y][playerPos.x] & transformerBlown && !(playerMovement[playerPos.y][playerPos.x] & onFire)):
      playerMovement[playerPos.y][playerPos.x] ^= transformerBlown
      increment_score()
      increaseDifficulty(difficultyIncrease)

  if nextMove == up && playerPos.y == topOfPole && playerState == extinguisherItem:
    soundMaker.play("extinguish", false)
    if(playerMovement[playerPos.y][playerPos.x] & onFire):
      playerMovement[playerPos.y][playerPos.x] ^= onFire
      increment_score()
      increaseDifficulty(difficultyIncrease)
    var stillOnFire = false
    for tran in transformerList:
      if playerMovement[tran.pos.y][tran.pos.x] & onFire:
        stillOnFire = true
    if not stillOnFire:
      fireStream.stop()
  elif playerMovement[playerPos.y][playerPos.x] & onFire:
      playerMovement[playerPos.y][playerPos.x] ^= playerPresent
      fireDeath = true
      print("Fire", false)
  pass

  if nextMove != stay && previousPos.y == topOfPole:
      extinguisher.set_opacity(lit)
      transformer.set_opacity(lit)
      playerState = noItem

  lightningHits(delta)
  update_sprites(delta)
#
  for action in keyMap:
    if !Input.is_action_pressed(action):
      keyMap.erase(action)

func lightningHits(delta):
	if timeLightningHit > 0:
		timeLightningHit -= delta
	else:
		for i in range(lightningSpriteList.size()):
			lightningSpriteList[i].set_opacity(0)
		var chance = randf()
		if chance > 0.99995:
			timeLightningHit = 0.5
			var transformerNumber = randi() % 6
			lightningSpriteList[transformerNumber].set_opacity(1)
			playerMovement[1][lightningToTransformer[transformerNumber]] |= transformerBlown
			playerMovement[1][lightningToTransformer[transformerNumber]] |= onFire
			print(playerMovement)

func _can_Move(currentPos,moveDir):
  var destPos = Vector2(currentPos.x, currentPos.y) + moveDir
  if(playerMovement[destPos.y][destPos.x] != 0):
    return true
  else:
    return false

func checkDeath():
  if(transformerDeath):
    print("transformer death happens")
    var spritesToPassIn = []
    for trans in transformerList:
      var broken = trans.brokenSprite
      broken.set_opacity(0)
      spritesToPassIn.append(broken)
      var fixed = trans.fixedSprite
      fixed.set_opacity(0)
      var largeFire = trans.largeFireSprite
      largeFire.set_opacity(0)
      spritesToPassIn.append(largeFire)
      var smallFire = trans.smallFireSprite
      smallFire.set_opacity(0)
    for sprite in spritesToPassIn:
      sprite.set_opacity(0)
    get_node("DeathNode").die(spritesToPassIn)
  elif(fireDeath):
    decrease_lives()
    soundMaker.play("fireburst", false)
    var spritesToPassIn = []
    if(playerPos.x == 2):
      spritesToPassIn.append(fireDeathSpriteList[0])
    elif(playerPos.x == 3):
      spritesToPassIn.append(fireDeathSpriteList[1])
    elif(playerPos.x == 5):
      spritesToPassIn.append(fireDeathSpriteList[2])
    elif(playerPos.x == 6):
      spritesToPassIn.append(fireDeathSpriteList[3])
    elif(playerPos.x == 8):
      spritesToPassIn.append(fireDeathSpriteList[4])
    elif(playerPos.x == 9):
      spritesToPassIn.append(fireDeathSpriteList[5])
    else:
      print("SOMETHING TERRIBLE HAPPENED WHEN DESICIDING THE FLAME DEATH SPRITE!!")
    get_node("DeathNode").die(spritesToPassIn)
  elif(poopDeath):
    soundMaker.play("splat", false)
    var spritesToPassIn = []
    spritesToPassIn.append(spriteMap[playerPos.y][playerPos.x][playerState])
    get_node("DeathNode").die(spritesToPassIn)
		
func transformerDeathCheck():
	var transformerAllDead = true
	for tran in transformerList:
		if(!playerMovement[tran.pos.y][tran.pos.x] & transformerBlown):
			transformerAllDead = false
	if(transformerAllDead == true):
		decrease_lives()
	transformerDeath = transformerAllDead
	
func poopDeathCheck():
	if(playerMovement[playerPos.y][playerPos.x] & birdPoop):
		playerMovement[playerPos.y][playerPos.x] ^= birdPoop
		playerMovement[playerPos.y][playerPos.x] ^= playerPresent
		poopDeath = true
		decrease_lives()

func play_walk_sound():
  if playWalkNoiseOne:
    soundMaker.play("walk1", false)
    pass
  else:
    soundMaker.play("walk2", false)
    pass
  playWalkNoiseOne = not playWalkNoiseOne

func update_sprites(delta):
  update_lives()
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
    trans._update(delta)

func load_lightning_sprites():
  var lightningImgList = get_node("SparkControlNode").list_files_in_directory(LIGHTNING_IMAGE_DIRECTORY)
  lightningSpriteList = []
  for i in range(lightningImgList.size()):
    lightningSpriteList.append([])
    var s = Sprite.new()
    s.set_texture(load(lightningImgList[i]))
    s.set_opacity(low)
    self.add_child(s)
    lightningSpriteList[i] = s


func load_flame_death_sprites():
  var flameDeathImgList = get_node("SparkControlNode").list_files_in_directory(FLAMBE_IMAGE_DIRECTORY)
  fireDeathSpriteList = []
  for i in range(flameDeathImgList.size()):
    fireDeathSpriteList.append([])
    var s = Sprite.new()
    s.set_texture(load(flameDeathImgList[i]))
    s.set_opacity(low)
    self.add_child(s)
    fireDeathSpriteList[i] = s

func _ready():
  randomize()
  playerMovement = get_node("/root/global").get("playerMovement")
  scoreControl = get_node("Score")
  scoreControl.value = 0

  load_lives()

  set_process(true)

  soundMaker = get_tree().get_root().get_node("/root/Node2D/SamplePlayer")
  fireStream = get_tree().get_root().get_node("/root/Node2D/StreamPlayerFire")

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

  load_lightning_sprites()

  transformerList.append(transformerBox.new(Vector2(2,1),1,playerMovement, transformerBlown, onFire))
  transformerList.append(transformerBox.new(Vector2(3,1),2,playerMovement, transformerBlown, onFire))
  transformerList.append(transformerBox.new(Vector2(5,1),3,playerMovement, transformerBlown, onFire))
  transformerList.append(transformerBox.new(Vector2(6,1),4,playerMovement, transformerBlown, onFire))
  transformerList.append(transformerBox.new(Vector2(8,1),5,playerMovement, transformerBlown, onFire))
  transformerList.append(transformerBox.new(Vector2(9,1),6,playerMovement, transformerBlown, onFire))

  playerMovement[1][3] |= transformerBlown
  playerMovement[1][5] |= transformerBlown
  playerMovement[1][6] |= transformerBlown

#  playerMovement[1][2] |= transformerBlown
#  playerMovement[1][8] |= transformerBlown
#  playerMovement[1][9] |= transformerBlown

  playerMovement[1][6] |= onFire

  for trans in transformerList:
    for sprite in trans.spriteGetter():
      self.add_child(sprite)

  var spitete = Sprite.new()
  spitete.set_texture(load("res://img/flambe/1.png"))
  spitete.set_opacity(off)
  self.add_child(spitete)

  spriteMap = []
  for row in range(playerMovement.size()):
    spriteMap.append([])
    for col in range(playerMovement[row].size()):
      spriteMap[row].append({})
      if(playerMovement[row][col] != 0):
        # Load player sprite
        load_sprite("player", row, col)

#       # Load player w/ extinguisher sprites
        load_sprite("extinguisher", row, col)

        # Load player w/ transformer sprites
        load_sprite("transformer", row, col)
  load_flame_death_sprites()

func update_lives():
	
	if lives < 3:
		life3.set_hidden(true)
	if lives < 2:
		life2.set_hidden(true)
	if lives < 1:
		life1.set_hidden(true)
	if lives < 0 :
		game_Over()
#               life3.set_hidden(true)
#       elif(lives == 1):
#               life2.set_hidden(true)
#       elif(lives <= 0 ):
#               life1.set_hidden(true)

func load_lives():
  life1 = Sprite.new()
  var spriteName = "res://img/life1.png"
  life1.set_texture(load(spriteName))
  life1.set_hidden(false)
  self.add_child(life1)

  life2 = Sprite.new()
  var spriteName2 = "res://img/life2.png"
  life2.set_texture(load(spriteName2))
  life2.set_hidden(false)
  self.add_child(life2)
  
  life3 = Sprite.new()
  var spriteName3 = "res://img/life3.png"
  life3.set_texture(load(spriteName3))
  life3.set_hidden(false)
  self.add_child(life3)

  gameOver = Sprite.new()
  var spriteName4 = "res://img/gameOver.png"
  gameOver.set_texture(load(spriteName4))
  gameOver.set_hidden(true)
  self.add_child(gameOver)

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

func resetPlayer():
  playerPos = Vector2(3, groundRow)
  playerMovement[playerPos.y][playerPos.x] |= playerPresent
  extinguisher.set_opacity(lit)
  transformer.set_opacity(lit)
  playerState = noItem
  transformerDeath = false
  fireDeath = false
  poopDeath = false

func game_Over():
	gameOver.set_hidden(false)
	soundMaker.stop_all()
	fireStream.stop()
	get_tree().get_root().get_node("/root/Node2D/StreamPlayer").stop()
	soundMaker.play("death")


func increment_score():
  scoreControl.value += 1

func decrease_lives():
  print(lives)
  lives -= 1

func increaseDifficulty(increaseNum):
  difficultyMod += increaseNum

class transformerBox:
  var pos
  var brokenSprite
  var fixedSprite
  var playerMap
  var blownTransformer
  var fireTransformer
  var largeFireSprite
  var smallFireSprite
  var fireToggle
  var fireTime

  func _init(position, transformerNum, playerMovement, transformerBlown, transformerOnFire):
    fireTime = 0.5
    fireToggle = 0
    pos = position
    blownTransformer = transformerBlown
    fireTransformer = transformerOnFire
    playerMap = playerMovement
    brokenSprite = Sprite.new()
    var spriteName = "res://img/brokenTrans/%s.png" % [transformerNum]
    brokenSprite.set_texture(load(spriteName))
    brokenSprite.set_opacity(0)

    fixedSprite = Sprite.new()
    var spriteName = "res://img/fixedTrans/%s.png" % [transformerNum]
    fixedSprite.set_texture(load(spriteName))
    fixedSprite.set_opacity(1)

    largeFireSprite = Sprite.new()
    var spriteName = "res://img/fire/%sl.png" % [transformerNum]
    largeFireSprite.set_texture(load(spriteName))
    largeFireSprite.set_opacity(1)

    smallFireSprite = Sprite.new()
    var spriteName = "res://img/fire/%ss.png" % [transformerNum]
    smallFireSprite.set_texture(load(spriteName))
    smallFireSprite.set_opacity(1)

  func _update(delta):
    #check player map for state
    #set sprite accordingly
    if((playerMap[pos.y][pos.x] & blownTransformer) != 0):
      if((playerMap[pos.y][pos.x] & fireTransformer) != 0):
        fireTime -= delta
        if fireTime < 0:
          if fireToggle % 3 == 0:
            self.largeFireSprite.set_opacity(0)
            self.smallFireSprite.set_opacity(0)
          elif fireToggle % 3 == 1:
            self.largeFireSprite.set_opacity(0)
            self.smallFireSprite.set_opacity(1)
          else:
            self.largeFireSprite.set_opacity(1)
            self.smallFireSprite.set_opacity(0)
          fireTime = 0.5
          fireToggle = (fireToggle + 1) % 3
      else:
        self.largeFireSprite.set_opacity(0)
        self.smallFireSprite.set_opacity(0)
        fireTime = 0.5

      self.brokenSprite.set_opacity(1)
      self.fixedSprite.set_opacity(0)
    else:
      self.largeFireSprite.set_opacity(0)
      self.smallFireSprite.set_opacity(0)
      self.brokenSprite.set_opacity(0)
      self.fixedSprite.set_opacity(1)

  func spriteGetter():
    return [fixedSprite,brokenSprite,largeFireSprite,smallFireSprite]
