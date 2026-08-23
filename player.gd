extends Creature
class_name Player

const move_distance := 1.0
const move_frames := 10
const dist_per_frame := move_distance / move_frames
const jump_height := 1

var _direction := Direction.NONE
var _frame := 0
var _start_pos : Vector3
var _direction_history: Array = [Direction.UP]



func _on_area_entered(area: Area3D) -> void:
	explode_animation()
	_die()

func _die() -> void:
	# Stop the player from reacting further and hide it
	set_physics_process(false)
	monitoring = false
	monitorable = false
	visible = false

	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func _ready() -> void:
	_start_pos = position
	rotation.y = direction_rotations[_direction_history[0]]
	# Setup collision detection
	area_entered.connect(_on_area_entered)


func _physics_process(_delta: float) -> void:
	if _direction == Direction.NONE:
		_read_input()
	else:
		_move_step()

func _read_input() -> void:
	for action in INPUT_TO_DIRECTION:
		if Input.is_action_just_pressed(action):
			_direction = INPUT_TO_DIRECTION[action]
			_direction_history.append(_direction)
			return

func _move_step() -> void:
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
		_direction = Direction.NONE
		print(position)
