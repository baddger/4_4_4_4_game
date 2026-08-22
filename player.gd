extends Node3D

const MOVE_DISTANCE := 1.0
const MOVE_FRAMES := 10
const DIST_PER_FRAME := MOVE_DISTANCE / MOVE_FRAMES

enum Direction { NONE, UP, DOWN, LEFT, RIGHT }

const DIRECTION_VECTORS := {
	Direction.UP: Vector3.BACK,      # (0, 0, -1)
	Direction.DOWN: Vector3.FORWARD, # (0, 0, 1)
	Direction.LEFT: Vector3.RIGHT,   # (1, 0, 0)
	Direction.RIGHT: Vector3.LEFT,   # (-1, 0, 0)
}

const DIRECTION_ROTATIONS := {
	Direction.UP: 1.0 * PI,
	Direction.DOWN: 2.0 * PI,
	Direction.LEFT: 1.5 * PI,
	Direction.RIGHT: 0.5 * PI,
}

const INPUT_TO_DIRECTION := {
	"ui_up": Direction.UP,
	"ui_down": Direction.DOWN,
	"ui_left": Direction.LEFT,
	"ui_right": Direction.RIGHT,
}

var _direction := Direction.NONE
var _rotation_step := 0.0
var _frame := 0

func _physics_process(_delta: float) -> void:
	if _direction == Direction.NONE:
		_read_input()
	else:
		_move_step()

func _read_input() -> void:
	for action in INPUT_TO_DIRECTION:
		if Input.is_action_just_pressed(action):
			_direction = INPUT_TO_DIRECTION[action]
			var delta_angle := wrapf(DIRECTION_ROTATIONS[_direction] - rotation.y, -PI, PI)
			_rotation_step = delta_angle / MOVE_FRAMES
			return

func _move_step() -> void:
	rotation.y = wrapf(rotation.y + _rotation_step, 0.0, TAU)

	position += DIRECTION_VECTORS[_direction] * DIST_PER_FRAME
	position = position.snapped(Vector3.ONE * 0.001)

	_frame += 1
	if _frame >= MOVE_FRAMES:
		_frame = 0
		_direction = Direction.NONE
