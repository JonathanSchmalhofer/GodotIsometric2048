extends Node2D

#const PawnTemplate = preload("res://scenes/pawn.tscn")
const GameMechanic = preload("res://game_mechanics_2048.gd")
onready var SwipeDirections = preload("res://addons/swipe-detector/directions.gd").new()

func _ready():
	var game_mechanic = GameMechanic.new()
	#var pawn_object = PawnTemplate.instance()
	
	$board.add_child(game_mechanic)
	for child in $board.get_children():
		if child is GameMechanics2048:
			child.initialize(0)
	#$board.add_child(pawn_object)
	#for child in $board.get_children():
	#	if child is Pawn:
	#		child.initialize(self)

# Swiping

func _on_SwipeDetector_swipe_started( partial_gesture ):
	var point = partial_gesture.last_point()

func _on_SwipeDetector_swipe_updated( partial_gesture ):
	var point = partial_gesture.last_point()

func _on_SwipeDetector_swipe_ended( gesture ):
	$SwipeDetector/Values/Direction.set_text(gesture.get_direction())
	$SwipeDetector/Values/Angle/Value.set_text(str(gesture.get_direction_angle()))
	$SwipeDetector/Values.show()

func _on_SwipeDetector_swiped( gesture ):
	if(SwipeDirections.DIRECTION_DOWN_RIGHT == gesture.get_direction()):
		_move_pawns_down_right()
	else: if(SwipeDirections.DIRECTION_DOWN_LEFT == gesture.get_direction()):
		_move_pawns_down_left()
	else: if(SwipeDirections.DIRECTION_UP_RIGHT == gesture.get_direction()):
		_move_pawns_up_right()
	else: if(SwipeDirections.DIRECTION_UP_LEFT == gesture.get_direction()):
		_move_pawns_up_left()

func _move_pawns_down_right():
	pass

func _move_pawns_down_left():
	for child in $board.get_children():
		if child is GameMechanics2048:
			child.left()
			return

func _move_pawns_up_right():
	pass

func _move_pawns_up_left():
	pass
