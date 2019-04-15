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

func initialize(maxLevel: int) -> void:
	_score = 0
	_turns = 0
	_maxLevel = maxLevel
	_win = false
	_loose = false
	print("Initializing Game")
	for x in range(4):
		_tiles.append([])
		_tiles[x].resize(4)
		for y in range(4):
			_tiles[x][y] = TileTemplate.new()
			_tiles[x][y].setCoordinates(Vector2(x,y))
	self.addTile()

func canMove() -> bool:
	return true

func left() -> void:
	print("Left")
	var addNewTileAfterMove = false
	for i in range(4):
		var line = getLine(i)
		#Tile[] merged = mergeLine(moveLine(line))
		#setLine(i, merged)
		var merged = moveLine(line)
		
		if (!addNewTileAfterMove && !compare(line, merged)):
			addNewTileAfterMove = true
	if addNewTileAfterMove:
		addTile()
		print("Add New Tile")

func getLine(index: int):
	var result = []
	for i in range(4):
		result.append(tileAt(i, index))
	return result

func tileAt(x: int, y: int):
	return self._tiles[x][y]

func addTile():
	var list = availableSpace()
	if !(list.empty()):
		randomize()
		var index = int(randi() % list.size())
		var pawn_object = PawnTemplate.instance()
		var board = self.get_parent().get_child(0)
		pawn_object.initialize(self)
		var value = 0
		if randf()  < 0.9:
			value = 2
		else:
			value = 4
		pawn_object.setValue(value)
		#pawn_object.positionAt((Vector2(2,2))
		board.add_child(pawn_object)

func availableSpace():
	var list = []
	for tileCol in _tiles:
		for tile in tileCol:
			if tile.empty():
				list.append(tile)
	return list

func moveLine(oldLine: Array) -> Array:
	var list = []
	for i in range(4):
		if (!(oldLine[i].empty())):
			list.append(oldLine[i])
	if (list.size() == 0):
		print("Empty")
		return oldLine
	else:
		var newLine = []
		list = ensureSize(list, 4)
		for i in range(4):
			newLine.append(list.pop_front())
		return newLine

func compare(line1: Array, line2: Array) -> bool:
	print("Comparing")
	if (line1 == line2):
		print("Identical")
		return true
	else: if(line1.size() != line2.size()):
		print("Different Size")
		return false
	for i in range(line1.size()):
		if (line1[i].getValue() != line2[i].getValue()):
			print("Different Value")
			return false
	print("Default")
	return true

func ensureSize(list: Array, size: int) -> Array:
	while (list.size() < size):
		list.append(TileTemplate.new())
	return list