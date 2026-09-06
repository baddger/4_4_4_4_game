extends Camera3D

## Node to keep centered in view. Defaults to the sibling node named "player".
@export var target_path: NodePath

## How quickly the camera catches up to the target's Z position.
## Higher values feel snappier, lower values feel "heavier" (more inertia).
## The default converges ~95% of the distance within about 10 physics
## frames (at 60 fps), matching the player's per-tile movement duration,
## so the camera stays smooth without ever falling noticeably behind.
@export var smoothing_speed: float = 3.0

## The camera only starts moving once the target is this many meters
## ahead of or behind its current followed position (dead zone).
@export var dead_zone_up: float = 6
@export var dead_zone_down: float = 6

# VALUE FOR ONE PLAYER
#@export var dead_zone_up: float = 1
#@export var dead_zone_down: float = 0
const pipe_scene = preload("res://pipe_2.tscn")

var _game_started := false


var _targets: Array[Node3D] = []  # List of all nodes with "player" in their name
var _z_offset: float
var _last_pipe_z: float = -9.0  # Track Z position of last spawned pipe
var _pipes: Array[Node3D] = []  # List to track spawned pipes

var _z_offset_pipe: float

func _on_game_started() -> void:
	_game_started = true

func _ready() -> void:

	_z_offset_pipe = global_position.z
	if target_path.is_empty():
		_find_all_player_targets()
	else:
		var target = get_node_or_null(target_path)
		if target:
			_targets.append(target)

	if _targets.size() > 0:
		_z_offset = global_position.z - _targets[0].global_position.z
	else:
		push_warning("camera_zqsd_and_mouse: no targets found to follow.")

	# Wait for the game to start before accepting input
	var game_master = get_tree().root.get_node("Node3D/GameMaster")
	if game_master:
		game_master.game_started.connect(_on_game_started)

func _get_min_target_z() -> float:
	"""Get the minimum Z position of all targets."""
	if _targets.is_empty():
		return global_position.z

	var min_z := INF
	for target in _targets:
		if is_instance_valid(target):
			min_z = min(min_z, target.global_position.z)

	return min_z if min_z != INF else global_position.z

func _find_all_player_targets() -> void:
	"""Find all nodes with 'player' in their name."""
	_targets.clear()
	var parent = get_parent()
	if not parent:
		return

	for child in parent.get_children():
		if child.name.to_lower().contains("player") and child is Node3D:
			_targets.append(child)

func _physics_process(delta: float) -> void:

	# Spawn all pipes needed for every 3 units of movement
	var pos := global_position.z - _z_offset_pipe
	while (pos - 30) < _last_pipe_z:
		_spawn_pipe(_last_pipe_z)
		_last_pipe_z -= 3.0

	if not _game_started :
		return
	if _targets.is_empty():
		return

	var target_z := _get_min_target_z() + _z_offset
	var diff := target_z - global_position.z

	#if diff > 0 and diff > dead_zone_down:
	#	var desired_z := target_z - signf(diff) * dead_zone_down
	#	var weight := 1.0 - exp(-smoothing_speed * delta)
	#	global_position.z = lerp(global_position.z, desired_z, weight)
	if diff < 0 and diff < -dead_zone_up:
		var desired_z := target_z - signf(diff) * dead_zone_up
		var weight := 1.0 - exp(-smoothing_speed * delta)
		global_position.z = lerp(global_position.z, desired_z, weight)

	global_position.z -= 0.01




var cpt = 0
func _spawn_pipe(pipe_z: float) -> void:
	var pipe = pipe_scene.instantiate()
	# Randomly set pipe color to RED or BLUE
	pipe.pipe_color = randi() % 8
	#pipe.pipe_color = cpt % 8
	#pipe.pipe_color = cpt % 8
	#cpt += 1
	#pipe.position.x -= 6.0
	var direction = randi() % 2
	if direction == 0:
		pipe.position.x -= 6.0
	else:
		pipe.position.x += 6.0
		pipe.rotation.y = PI
	get_parent().add_child(pipe)  # Add to scene tree first
	# Now set global position after it's in the tree
	pipe.global_position.z = pipe_z
	# Add pipe to list
	_pipes.append(pipe)
	# Remove oldest pipe if list contains 3 or more
	if _pipes.size() > 20:
		var old_pipe = _pipes.pop_front()
		old_pipe.queue_free()
