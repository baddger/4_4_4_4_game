extends Creature
class_name Player


func _ready() -> void:
	# Setup collision detection
	area_entered.connect(_on_area_entered)

	_direction = Direction.NONE
	_direction_history = [Direction.UP]
	rotation.y = direction_rotations[Direction.UP]

func _on_area_entered(area: Area3D) -> void:
	explode_animation()
	_die()

func _physics_process(_delta: float) -> void:
	if _direction == Direction.NONE:
		_read_input()
	else:
		var move_frames = 15
		var jump_height = 5.0
		_move_step(move_frames, jump_height)
		if _frame >= move_frames:
			_frame = 0
			_direction = Direction.NONE

func _read_input() -> void:
	for action in INPUT_TO_DIRECTION:
		if Input.is_action_just_pressed(action):
			_direction = INPUT_TO_DIRECTION[action]
			_direction_history.append(_direction)
			return

func _die() -> void:
	# Stop the player from reacting further and hide it
	set_physics_process(false)
	area_entered.disconnect(_on_area_entered)
	monitoring = false
	monitorable = false
	visible = false

	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
