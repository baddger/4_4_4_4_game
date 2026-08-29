extends Creature
class_name Car

enum PipeColor { BLUE, RED }
@export var pipe_color: PipeColor = PipeColor.BLUE

var material_blue = preload("res://frog_car/material_car_blue.tres")
var material_red = preload("res://frog_car/material_car_red.tres")

var _direction_sequence: Array
var _sequence_index := 0

func _ready() -> void:
	var mesh_node = get_node("frog/frog_paint_texture_0")
	if pipe_color == PipeColor.BLUE :
		_direction_sequence = [Direction.RIGHT, Direction.RIGHT, Direction.UP, Direction.RIGHT, Direction.RIGHT, Direction.DOWN]
		mesh_node.set_surface_override_material(0, material_blue)
	if pipe_color == PipeColor.RED :
		_direction_sequence = [Direction.RIGHT]
		mesh_node.set_surface_override_material(0, material_red)

	next_in_sequence()
	_direction_history.append(_direction)
	_position_history.append(position)
	_rotation_history.append(rotation)
	
	rotation.y = direction_rotations[_direction_history[0]]



func _physics_process(_delta: float) -> void:

	# hors limite
	if abs(position.x) > 20 or abs(position.y) > 20:
		print(position)
		queue_free()
		return

	var move_frames = 30
	var jump_height = 0.0
	_move_step(move_frames, jump_height)

	if _frame >= move_frames:
		_frame = 0
		next_in_sequence()

func next_in_sequence() :
	_sequence_index = (_sequence_index) % _direction_sequence.size()
	_direction = _direction_sequence[_sequence_index]
	_direction_history.append(_direction)
	_position_history.append(position)
	_rotation_history.append(rotation)
	_sequence_index += 1
