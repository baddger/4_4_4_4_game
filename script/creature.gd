extends Area3D
class_name Creature

const move_distance := 1.0

var _frame := 0
var _start_pos := position
var _state_history: Array
var _position_history: Array
var _rotation_history: Array

enum st8 { NONE, UP, DOWN, LEFT, RIGHT, BACKFLIP }

const direction_vectors := {
	st8.UP: Vector3.FORWARD,
	st8.DOWN: Vector3.BACK,
	st8.LEFT: Vector3.LEFT,
	st8.RIGHT: Vector3.RIGHT,
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
	var dist_per_frame = direction_vectors[get_last_direction_state()] * (move_distance / move_frames)
	var dist = _frame * dist_per_frame
	position = _position_history[-1] +  dist
	position = position.snapped(Vector3.ONE * 0.001)

		# Gestion rotation
	var prev_rotation = _rotation_history[-1].y
	var target_rotation = direction_rotations[get_last_direction_state()]
	var delta_angle := wrapf(target_rotation - prev_rotation, -PI, PI)
	var rotation_step = delta_angle / move_frames
	rotation.y += rotation_step
	rotation.y = wrapf(rotation.y, 0.0, TAU)
	pass


func _move_step(move_frames : int, jump_height: float) -> void:

	_frame += 1
	# Gestion rotation
	var prev_rotation = _rotation_history[-1].y
	var target_rotation = direction_rotations[get_last_direction_state()]
	var delta_angle := wrapf(target_rotation - prev_rotation, -PI, PI)
	var rotation_step = delta_angle / move_frames
	rotation.y += rotation_step
	rotation.y = wrapf(rotation.y, 0.0, TAU)

	# Gestion movement
	var dist_per_frame = direction_vectors[get_last_direction_state()] * (move_distance / move_frames)
	var dist = _frame * dist_per_frame
	position = _position_history[-1] +  dist

	# Gestion saut
	var step_size := float(_frame) / move_frames
	# trajectoire parabolique
	var jump = jump_height * step_size * (1.0 - step_size)
	position.y = _start_pos.y + jump
	position = position.snapped(Vector3.ONE * 0.001)

func set_state(state) :
	_state_history.append(state)
	_position_history.append(position)
	_rotation_history.append(rotation)

func get_sate() :
	return _state_history[-1]
