extends KinematicBody2D
class_name Pawn

onready var _tween : Tween = $Tween
export var _sliding_time : = 0.5

var _tilemap : TileMap
var _value : = 0
var _sliding : = false

func moveTo(position: Vector2) -> void:
	var offset = self.get_parent().get_parent().position
	var move_to = self.get_parent().map_to_world(position) + offset
	_tween.interpolate_property(
		self,
		"global_position",
		global_position,
		move_to,
		_sliding_time,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT)
	_tween.start()
	yield(_tween, "tween_completed")

func positionAt(position: Vector2) -> void:
	var offset = self.get_parent().get_parent().position
	self.position = self.get_parent().map_to_world(position) + offset

func initialize(tilemap: TileMap) -> void:
	_tilemap = tilemap

func setValue(value: int) -> void:
	_value = value

func getValue() -> int:
	return _value