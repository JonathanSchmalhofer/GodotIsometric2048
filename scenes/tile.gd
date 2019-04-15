extends Pawn
class_name Tile

var _x : = 0
var _y : = 0

func setCoordinates(vec: Vector2):
	_x = vec.x
	_y = vec.y

func empty() -> bool:
	if _value == 0:
		return true
	else:
		return false