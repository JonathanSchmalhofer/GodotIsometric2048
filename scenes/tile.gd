extends Node2D
class_name Tile

var _x : = 0
var _y : = 0
var _value : = 0

func setValue(value: int) -> void:
	_value = value

func getValue() -> int:
	return _value

func setCoordinates(vec: Vector2) -> void:
	_x = vec.x
	_y = vec.y

func getCoordinates() -> Vector2:
	return Vector2(_x,_y)

func empty() -> bool:
	return (_value == 0)

func printCoordinates() -> void:
	print("(" + str(_x) + "," + str(_y) + ") = " + str(_value))