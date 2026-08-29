extends Area3D
class_name Creature

const move_distance := 1.0

var _frame := 0
var _state_history: Array
var _position_history: Array
var _rotation_history: Array

enum st8 { NONE, UP, DOWN, LEFT, RIGHT, BACKFLIP }

const direction_vectors := {
	st8.UP: Vector3.FORWARD,
	st8.DOWN: Vector3.BACK,
	st8.LEFT: Vector3.LEFT,
	st8.RIGHT: Vector3.RIGHT,
	st8.NONE: Vector3.ZERO,
}

const direction_rotations := {
	st8.DOWN:  0,
	st8.RIGHT: 0.5 * PI,
	st8.UP:    1.0 * PI,
	st8.LEFT:  1.5 * PI,
}

func get_last_direction_state() -> st8:
	"""Retrieve the last direction in history that is not NONE or BACKFLIP."""
	for i in range(_state_history.size() - 1, -1, -1):
		var state = _state_history[i]
		if state != st8.NONE and state != st8.BACKFLIP:
			return state
	return st8.NONE

func _move_step_back(move_frames : int, _jump_height: float) -> void:
	_frame += 1

	# Gestion movement
	var start = _position_history[-1]
	var end = _position_history[-2]
	translation(start, end, move_frames)

	# Gestion rotation
	var prev_rotation = _rotation_history[-1].y
#	var target_rotation = _rotation_history[-2].y
	var target_rotation = direction_rotations[_state_history[-2]]

	y_rotate(prev_rotation, target_rotation, move_frames)


	var rotation_step = - (TAU / move_frames)
	rotation.x = _rotation_history[-1].x + (rotation_step * _frame)
	rotation.x = wrapf(rotation.x, 0.0, TAU)

	# Gestion saut
	var start_pos = _position_history[-1].y
	var jump_height = 5.0
	var end_pos = _position_history[-2].y

	var step_size := float(_frame) / move_frames
	# Parabolic trajectory: interpolate from start_pos to end_pos + upward arc
	var vertical_movement = (end_pos - start_pos) * step_size
	var jump_arc = jump_height * step_size * (1.0 - step_size) # trajectoire parabolique
	position.y = start_pos + vertical_movement + jump_arc

func translation(start : Vector3, end: Vector3, move_frames : float) -> void:
	var trans = end - start
	var new_position = start + trans * (_frame / move_frames)
	new_position = new_position.snapped(Vector3.ONE * 0.001)
	position.x = new_position.x
	position.z = new_position.z


func y_rotate(prev_rotation : float, target_rotation: float, move_frames : float) -> void:
	var delta_angle := wrapf(target_rotation - prev_rotation, -PI, PI)
	var rotation_step = delta_angle / move_frames
	rotation.y = prev_rotation + (rotation_step * _frame)
	rotation.y = wrapf(rotation.y, 0.0, TAU)


func _move_step(move_frames : int, jump_height: float) -> void:

	_frame += 1
	# Gestion rotation
	var prev_rotation = _rotation_history[-1].y
	var target_rotation = direction_rotations[get_last_direction_state()]

	y_rotate(prev_rotation, target_rotation, move_frames)
	# Gestion movement
	var start = _position_history[-1]
	var end = _position_history[-1] + direction_vectors[get_state()]
	translation(start, end, move_frames)


	# Gestion saut
	var step_size := float(_frame) / move_frames
	var jump = jump_height * step_size * (1.0 - step_size) # trajectoire parabolique
	position.y = _position_history[-1].y + jump


	position = position.snapped(Vector3.ONE * 0.001)

func set_state(state) :
	_state_history.append(state)
	_position_history.append(position)
	_rotation_history.append(rotation)

func get_state() :
	return _state_history[-1]
