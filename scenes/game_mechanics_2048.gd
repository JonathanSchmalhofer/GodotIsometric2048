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
		addNewTileAfterMove = merge(tilesetCoordinates) or addNewTileAfterMove
		addNewTileAfterMove = squeeze(tilesetCoordinates) or addNewTileAfterMove #  by merging, some gaps could have appeared that should not exist
		#### PERFORM ANIMATIONS
		# TODO
		# Move Animation into separare Function
#		for animationIndex in range(_slideAnimations.size()):
#			#print(_slideAnimations[animationIndex])
#			#print(_tiles[0][0].getPawn())
#			_tiles[_slideAnimations[animationIndex][0]][_slideAnimations[animationIndex][1]].movePawnTo(Vector2(_slideAnimations[animationIndex][2],_slideAnimations[animationIndex][3]))
#			#print(_tiles[0][0].getPawn())
#			#print(_tiles[_slideAnimations[animationIndex][0]][_slideAnimations[animationIndex][1]].getPawn())
#			_tiles[_slideAnimations[animationIndex][2]][_slideAnimations[animationIndex][3]].setPawn(_tiles[_slideAnimations[animationIndex][0]][_slideAnimations[animationIndex][1]].getPawn())
#			#_tiles[_slideAnimations[animationIndex][0]][_slideAnimations[animationIndex][1]].setPawn(null)
#			#print(_tiles[_slideAnimations[animationIndex][2]][_slideAnimations[animationIndex][3]].getPawn())
#		_slideAnimations.clear()
#		for child in self._tilemap.get_node("YSort").get_children():
#			print("Child")
#			if child is Pawn:
#				print(self._tilemap.world_to_map(child.position))
	if (addNewTileAfterMove == true):
		addRandomPawn()
	self.printBoard()

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
		var currentPointer = idx - 1
		if !(_tiles[coordinateList[idx].x][coordinateList[idx].y].empty()): # only move non-empty tiles
			while currentPointer >= 0 && _tiles[coordinateList[currentPointer].x][coordinateList[currentPointer].y].empty():
				#### TODO
				# - put in separate function
				# - add move function for pawns as well
				var oldValue : int = _tiles[coordinateList[currentPointer+1].x][coordinateList[currentPointer+1].y].getValue()
				_tiles[coordinateList[currentPointer].x][coordinateList[currentPointer].y].setValue( oldValue )
				_tiles[coordinateList[currentPointer+1].x][coordinateList[currentPointer+1].y].setValue( 0 )
				####
				currentPointer -= 1
				somethingChanged = true
				# only add animations where start and goal are different
			if (coordinateList[idx].x != coordinateList[currentPointer+1].x and coordinateList[idx].y != coordinateList[currentPointer+1].x):
				_slideAnimations.append([coordinateList[idx].x, coordinateList[idx].y,coordinateList[currentPointer+1].x,coordinateList[currentPointer+1].y]) # Order is [startX, startY, goalX, goalY]; +1 because currentPointer always get decreased before exiting the loop
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
	return somethingChanged