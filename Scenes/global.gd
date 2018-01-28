# global information for all the game to share

extends Node

var moveableSpace = 1 << 0
var playerPresent = 1 << 1
var extinguisherSpawned = 1 << 2
var transformerSpawned = 1 << 3
var onFire = 1 << 4
var birdPoop = 1 << 5
var transformerBlown = 1 << 6

var playerMovement
					
func _ready():
	playerMovement=[[0,0,0,0,0,0,0,0,0,0,0,0],
					[0,0,1,1,0,1,1,0,1,1,0,0],
					[0,0,1,1,0,1,1,0,1,1,0,0],
					[0,0,1,1,0,1,1,0,1,1,0,0],
					[0,1,1,1,1,1,1,1,1,1,1,0],
					[0,0,0,0,0,0,0,0,0,0,0,0]]
					
					
					
