extends Creature
class_name Player_Multi

var stun := false
var _game_started := false

const input_to_state := {
	"ui_up": st8.UP,
	"ui_down": st8.DOWN,
	"ui_left": st8.LEFT,
	"ui_right": st8.RIGHT,
}

@export var player_action: String = "ui_up"


func _ready() -> void:
	# Setup collision detection
	area_entered.connect(_on_area_entered)
	set_state(st8.UP)
	set_state(st8.NONE)

	rotation.y = direction_rotations[get_last_direction_state()]

	# Wait for the game to start before accepting input
	var game_master = get_tree().root.get_node("Node3D/GameMaster")
	if game_master:
		game_master.game_started.connect(_on_game_started)

func _on_area_entered(_area: Area3D) -> void:
	if _area.name.contains("portal_to_death"):
		portal = _area
		await get_tree().create_timer(3.0).timeout
		queue_free()

	if _area is not Car :
		return
	if not stun :
		var stun_scene = load("res://stun.tscn")
		var stun_instance = stun_scene.instantiate()
		add_child(stun_instance)
		stun = true
		set_state(st8.BACKFLIP)
		_frame = 0
		# Reset stun after 2 seconds
		stun_instance.position.y += 0.8
		await get_tree().create_timer(1.0).timeout
		stun = false
		stun_instance.queue_free()

func _physics_process(_delta: float) -> void:

	if portal :
		translation_to_death(global_position, portal.global_position)
		return

	_read_input()
	if get_state() != st8.NONE:
		var move_frames = 20
		var camera = get_tree().root.get_node("Node3D/Camera3D")
		var is_last_player = camera.one_left() if camera else false
		if is_last_player :
			move_frames = 50
		var jump_height = 5.0
		if get_state() != st8.BACKFLIP :
			_move_step(move_frames, jump_height)
		else :
			_move_step_back(move_frames, jump_height)
		if _frame >= move_frames:
			_frame = 0
			set_state(st8.NONE)

func _read_input() -> void:

	# Check if only one player left
	var camera = get_tree().root.get_node("Node3D/Camera3D")
	var is_last_player = camera.one_left() if camera else false
	if is_last_player :
		if get_state() == st8.NONE:
			if(get_last_direction_state() == st8.LEFT):
				set_state(st8.RIGHT)
			else:
				set_state(st8.LEFT)
			return
		elif get_state() == st8.BACKFLIP:
			return
		else :
			set_state(st8.BACKFLIP)
			_frame = 0
			return

	if not _game_started or stun:
		return
	if get_state() == st8.NONE:
		if Input.is_action_just_pressed(player_action):
			print(position)
			var new_state = st8.UP
			set_state(new_state)
			return
	elif get_state() == st8.BACKFLIP:
		return
	else :
		if Input.is_action_just_pressed(player_action):
			set_state(st8.BACKFLIP)
			_frame = 0
			return

func _on_game_started() -> void:
	_game_started = true

func _die() -> void:
	# Stop the player from reacting further and hide it
	set_physics_process(false)
	monitoring = false
	monitorable = false
	visible = false
	queue_free()
	#await get_tree().create_timer(2.0).timeout
	#get_tree().reload_current_scene()
