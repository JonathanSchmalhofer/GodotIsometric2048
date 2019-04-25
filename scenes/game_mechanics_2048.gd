extends Node2D
class_name GameMechanics2048

const TileTemplate = preload("res://scenes/tile.gd")
const PawnTemplate = preload("res://scenes/pawn.tscn")

var _score : = 0
var _turns : = 0
var _maxLevel : = 0
var _win : = false
var _loose : = false
var _tiles : = []
var _slideAnimations : = []
var _mergeAnimations : = []
var _removeAnimations := []

onready var _tilemap : = get_node("/root/game/board")
const kMapSize : = 4

const kLeftDirection : int = 0
const kUpDirection : int = 1
const kRightDirection : int = 2
const kDownDirection : int = 3

func printBoard() -> void:
	var output : String = ""
	for y in range(kMapSize):
		for x in range(kMapSize):
			output += "[" + String(self._tiles[x][y].getValue()) + "] "
		output += "\n"
	print(output)

func initialize(maxLevel: int) -> void:
	_score = 0
	_turns = 0
	_maxLevel = maxLevel
	_win = false
	_loose = false
	print("Initializing Game")
	for x in range(kMapSize):
		_tiles.append([])
		_tiles[x].resize(kMapSize)
		for y in range(kMapSize):
			_tiles[x][y] = TileTemplate.new()
			_tiles[x][y].setCoordinates(Vector2(x,y))
			_tiles[x][y].setValue(0)
	#self.addRandomPawn()
	self.addPawnAt(Vector2(0,0), 2)
	#self.addPawnAt(Vector2(0,2), 2)
	#self.addPawnAt(Vector2(0,1), 2)
	self.addPawnAt(Vector2(2,0), 2)
	self.addPawnAt(Vector2(3,2), 2)
	#self.addPawnAt(Vector2(1,1), 2)
	self.printBoard()

func canMove() -> bool:
	return true

func squeezeAndMerge(direction: int) -> void:
	var addNewTileAfterMove : bool = false
	for i in range(kMapSize):
		var tilesetCoordinates = []
		match direction:
			kLeftDirection:
				tilesetCoordinates = getCoordinatesOfReverseColumnWithXEqual(i)
			kUpDirection:
				tilesetCoordinates = getCoordinatesOfRowWithYEqual(i)
			kRightDirection:
				tilesetCoordinates = getCoordinatesOfColumnWithXEqual(i)
			kDownDirection:
				tilesetCoordinates = getCoordinatesOfReverseRowWithYEqual(i)
		addNewTileAfterMove = squeeze(tilesetCoordinates) or addNewTileAfterMove # or-operand is required as some columns might not change. Yet, if one column changes a new tile shall be added.
		#print("Squeeze 1")
		#self.printBoard()
		addNewTileAfterMove = merge(tilesetCoordinates) or addNewTileAfterMove
		#rint("Merge")
		#self.printBoard()
		addNewTileAfterMove = squeeze(tilesetCoordinates) or addNewTileAfterMove #  by merging, some gaps could have appeared that should not exist
		#print("Squeeze 2")
		#self.printBoard()
		print("Slides: " + str(_slideAnimations.size()))
	#### PERFORM ANIMATIONS
	# TODO
	# Move all animations into separare function
	var animationPawn : Pawn = null
	
	# Sliding
	# TODO
	#  -merge sliding animations, if there is something like [a,b,c,d] and [c,d,e,f] --> to [a,b,e,f]
	for animationIndex in range(_slideAnimations.size()):
		print(_slideAnimations[animationIndex])
		animationPawn = self.getPawnAt(Vector2(_slideAnimations[animationIndex][0],_slideAnimations[animationIndex][1]))
		if null != animationPawn:
			animationPawn.moveTo(Vector2(_slideAnimations[animationIndex][2],_slideAnimations[animationIndex][3]))
			print("Moving from: (" + str(_slideAnimations[animationIndex][0]) + "," + str(_slideAnimations[animationIndex][1]) + ") to (" + str(_slideAnimations[animationIndex][2]) + "," + str(_slideAnimations[animationIndex][3]) + ")")
	_slideAnimations.clear()
	
	# Merging
	# TODO
	#  -implement merging animation
	_mergeAnimations.clear()
	
	# Removing
	for animationIndex in range(_removeAnimations.size()):
		#print(_slideAnimations[animationIndex])
		animationPawn = self.getPawnAt(Vector2(_removeAnimations[animationIndex][0],_removeAnimations[animationIndex][1]))
		if null != animationPawn:
			self.getPawnAt(Vector2(_removeAnimations[animationIndex][0],_removeAnimations[animationIndex][1])).queue_free()
			print("Removing: (" + str(_removeAnimations[animationIndex][0]) + "," + str(_removeAnimations[animationIndex][1]) + ")")
	_removeAnimations.clear()
	
	#for child in self._tilemap.get_node("YSort").get_children():
	#	print("Child")
	#	if child is Pawn:
	#		print(self._tilemap.world_to_map(child.position))
	#if (addNewTileAfterMove == true):
	#	addRandomPawn()
	self.printBoard()
	print("#######################")

func getPawnAt(position: Vector2) -> Pawn:
	for child in self._tilemap.get_node("YSort").get_children():
		if child is Pawn:
			if position == self._tilemap.world_to_map(child.position):
				return child
	return null

func getCoordinatesOfColumnWithXEqual(index: int):
	var result = []
	for i in range(kMapSize):
		result.append(Vector2(index, i))
	return result

func getCoordinatesOfReverseColumnWithXEqual(index: int):
	var result = []
	for i in range(kMapSize-1, -1, -1):
		result.append(Vector2(index, i))
	return result

func getCoordinatesOfRowWithYEqual(index: int):
	var result = []
	for i in range(kMapSize):
		result.append(Vector2(i, index))
	return result

func getCoordinatesOfReverseRowWithYEqual(index: int):
	var result = []
	for i in range(kMapSize-1, -1, -1):
		result.append(Vector2(i, index))
	return result

func addRandomPawn():
	var list = getEmptyTiles()
	if !(list.empty()):
		randomize()
		var index = randi() % list.size() #int(randi() % list.size())
		var value = 0
		if randf()  < 0.9:
			value = 2
		else:
			value = 4
		var coordinates : Vector2 = list[index].getCoordinates()
		self.addPawnAt(coordinates, value)

func addPawnAt(coordinates: Vector2, value: int):
	var pawn_object = PawnTemplate.instance()
	_tiles[coordinates.x][coordinates.y].setValue(value)
	pawn_object.positionAt(self._tilemap.map_to_world(coordinates))
	self._tilemap.get_node("YSort").add_child(pawn_object)

func getEmptyTiles():
	var list = []
	for tileCol in _tiles:
		for tile in tileCol:
			if tile.empty():
				list.append(tile)
	return list

func squeeze(coordinateList: Array) -> bool:
	var somethingChanged  = false
	for idx in range(coordinateList.size()): # start at second element (via currentPointer) and shift upward
		var currentChanged = false
		var currentPointer = idx - 1
		if !(_tiles[coordinateList[idx].x][coordinateList[idx].y].empty()): # only move non-empty tiles
			while currentPointer >= 0 && _tiles[coordinateList[currentPointer].x][coordinateList[currentPointer].y].empty():
				#### TODO
				# - put in separate function
				var oldValue : int = _tiles[coordinateList[currentPointer+1].x][coordinateList[currentPointer+1].y].getValue()
				_tiles[coordinateList[currentPointer].x][coordinateList[currentPointer].y].setValue(oldValue)
				_tiles[coordinateList[currentPointer+1].x][coordinateList[currentPointer+1].y].setValue(0)
				currentPointer -= 1
				somethingChanged = true
				currentChanged = true
			# only add animations when this (!) pawn has been moved at least once
			if (currentChanged):
				# Order is [startX, startY, goalX, goalY]
				_slideAnimations.append([coordinateList[idx].x, coordinateList[idx].y,coordinateList[currentPointer+1].x,coordinateList[currentPointer+1].y]) # +1 because currentPointer always get decreased before exiting the loop
	return somethingChanged

func merge(coordinateList: Array) -> bool:
	var somethingChanged  = false
	for idx in range(coordinateList.size() - 1): # we merge "upwards" in the list, so the last element has no successor to merge with
		if !(_tiles[coordinateList[idx].x][coordinateList[idx].y].empty()): # only merge non-empty tiles
			if _tiles[coordinateList[idx].x][coordinateList[idx].y].getValue() == _tiles[coordinateList[idx+1].x][coordinateList[idx+1].y].getValue():
				# Double the value and set the other to zero
				# TODO:
				# - add triggering of animation
				# - remove one pawn
				_tiles[coordinateList[idx].x][coordinateList[idx].y].setValue(2 * _tiles[coordinateList[idx].x][coordinateList[idx].y].getValue())
				_tiles[coordinateList[idx+1].x][coordinateList[idx+1].y].setValue(0)
				somethingChanged = true
				# Animation
				# Order is [posX, posY]
				_mergeAnimations.append([coordinateList[idx].x,coordinateList[idx].y])
				# Order is [posX, posY]
				_removeAnimations.append([coordinateList[idx+1].x,coordinateList[idx+1].y])
	return somethingChanged