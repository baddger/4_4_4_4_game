extends Node3D

const move_distance := 1.0
const move_frames := 30
const dist_per_frame := move_distance / move_frames
const jump_height := 1

enum PipeColor { BLUE, RED }

@export var pipe_color: PipeColor = PipeColor.BLUE

var _direction := Direction.RIGHT
var _frame := 0
var _start_pos : Vector3
var _direction_sequence: Array
var _direction_history: Array

var _sequence_index := 0

enum Direction { NONE, UP, DOWN, LEFT, RIGHT }

const direction_vectors := {
	Direction.UP: Vector3.FORWARD,
	Direction.DOWN: Vector3.BACK,
	Direction.LEFT: Vector3.LEFT,
	Direction.RIGHT: Vector3.RIGHT,
}

const direction_rotations := {
	Direction.DOWN:  0,
	Direction.RIGHT: 0.5 * PI,
	Direction.UP:    1.0 * PI,
	Direction.LEFT:  1.5 * PI,
}

const INPUT_TO_DIRECTION := {
	"ui_up": Direction.UP,
	"ui_down": Direction.DOWN,
	"ui_left": Direction.LEFT,
	"ui_right": Direction.RIGHT,
}

func _ready() -> void:

	if pipe_color == PipeColor.BLUE :
		_direction_sequence = [Direction.RIGHT, Direction.RIGHT, Direction.UP, Direction.RIGHT, Direction.RIGHT, Direction.DOWN]
		_set_material("res://frog_car/material_car_blue.tres")
	if pipe_color == PipeColor.RED :
		_direction_sequence = [Direction.RIGHT, Direction.RIGHT]
		_set_material("res://frog_car/material_car_red.tres")

	_direction_history = [_direction_sequence[0]]

	_start_pos = position
	_direction = _direction_sequence[_sequence_index]
	_direction_history.append(_direction)
	_sequence_index += 1
	rotation.y = direction_rotations[_direction_history[0]]

func _physics_process(_delta: float) -> void:

	_move_step()

func _read_input() -> void:
	for action in INPUT_TO_DIRECTION:
		if Input.is_action_just_pressed(action):
			_direction = INPUT_TO_DIRECTION[action]
			_direction_history.append(_direction)
			return

func _move_step() -> void:
	# Check if any coordinate exceeds 100
	if abs(position.x) > 20 or abs(position.y) > 20 or abs(position.z) > 20:
		print(position)
		queue_free()
		return

	_frame += 1

	# Gestion rotation
	var prev_rotation = direction_rotations[_direction_history[-2]]
	var target_rotation = direction_rotations[_direction]
	var delta_angle := wrapf(target_rotation - prev_rotation, -PI, PI)
	var rotation_step = delta_angle / move_frames
	rotation.y += rotation_step
	rotation.y = wrapf(rotation.y, 0.0, TAU)

	# Gestion movement
	position += direction_vectors[_direction] * dist_per_frame

	# Gestion saut
	var step_size := float(_frame) / move_frames
	# trajectoire parabolique
	var jump = jump_height * step_size * (1.0 - step_size)
	position.y = _start_pos.y + jump
	position = position.snapped(Vector3.ONE * 0.001)

	if _frame >= move_frames:
		_frame = 0
		_sequence_index = (_sequence_index) % _direction_sequence.size()
		_direction = _direction_sequence[_sequence_index]
		_direction_history.append(_direction)
		_sequence_index += 1

func _set_material(material_path: String) -> void:
	var mesh_node = get_node("frog/frog_paint_texture_0")
	if mesh_node:
		var material = load(material_path)
		if material:
			mesh_node.set_surface_override_material(0, material)
