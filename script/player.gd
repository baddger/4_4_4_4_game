extends Creature
class_name Player

var stun := false

const input_to_state := {
	"ui_up": st8.UP,
	"ui_down": st8.DOWN,
	"ui_left": st8.LEFT,
	"ui_right": st8.RIGHT,
}


func _ready() -> void:
	# Setup collision detection
	area_entered.connect(_on_area_entered)
	set_state(st8.UP)
	set_state(st8.NONE)


	rotation.y = direction_rotations[get_last_direction_state()]

func _on_area_entered(_area: Area3D) -> void:
	area_entered.disconnect(_on_area_entered)
	Utilities.explode_animation(global_position)
	# Add stun effect as child node
	var stun_scene = load("res://stun.tscn")
	var stun_instance = stun_scene.instantiate()
	add_child(stun_instance)
	stun = true
	# Reset stun after 2 seconds
	await get_tree().create_timer(2.0).timeout
	stun = false
	_die()

func _physics_process(_delta: float) -> void:
	_read_input()
	if get_state() != st8.NONE:
		var move_frames = 20
		var jump_height = 5.0
		if get_state() != st8.BACKFLIP :
			_move_step(move_frames, jump_height)
		else :
			_move_step_back(move_frames, jump_height)
		if _frame >= move_frames:
			_frame = 0
			set_state(st8.NONE)

func _read_input() -> void:
	if get_state() == st8.NONE:
		for action in input_to_state:
				if Input.is_action_just_pressed(action):
					print(position)
					var new_state = input_to_state[action]
					if position.x == 5 and new_state == st8.RIGHT:
						return
					if position.x == -5 and new_state == st8.LEFT:
						return
					set_state(new_state)


					return
	elif get_state() == st8.BACKFLIP:
		return
	else :
		for action in input_to_state:
				if Input.is_action_just_pressed(action):
					set_state(st8.BACKFLIP)
					_frame = 0
					return

func _die() -> void:
	# Stop the player from reacting further and hide it
	set_physics_process(false)
	monitoring = false
	monitorable = false
	visible = false
	queue_free()
	#await get_tree().create_timer(2.0).timeout
	#get_tree().reload_current_scene()
