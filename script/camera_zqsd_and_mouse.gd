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
@export var dead_zone_up: float = 15
@export var dead_zone_down: float = 15

# VALUE FOR ONE PLAYER
#@export var dead_zone_up: float = 1
#@export var dead_zone_down: float = 0
const pipe_scene = preload("res://pipe_2.tscn")



var _target: Node3D
var _z_offset: float
var _last_pipe_z: float = -4.0  # Track Z position of last spawned pipe
var _pipes: Array[Node3D] = []  # List to track spawned pipes

var _z_offset_pipe: float

func _ready() -> void:

	_z_offset_pipe = global_position.z
	if target_path.is_empty():
		_target = get_parent().get_node_or_null("player")
	else:
		_target = get_node_or_null(target_path)

	if _target:
		_z_offset = global_position.z - _target.global_position.z
	else:
		push_warning("camera_zqsd_and_mouse: no target found to follow.")


func _physics_process(delta: float) -> void:
	if not _target:
		return

	var target_z := _target.global_position.z + _z_offset
	var diff := target_z - global_position.z

	if diff > 0 and diff > dead_zone_down:
		var desired_z := target_z - signf(diff) * dead_zone_down
		var weight := 1.0 - exp(-smoothing_speed * delta)
		global_position.z = lerp(global_position.z, desired_z, weight)
	if diff < 0 and diff < -dead_zone_up:
		var desired_z := target_z - signf(diff) * dead_zone_up
		var weight := 1.0 - exp(-smoothing_speed * delta)
		global_position.z = lerp(global_position.z, desired_z, weight)

	# Spawn all pipes needed for every 3 units of movement
	var pos := global_position.z - _z_offset_pipe
	while (pos - 30) < _last_pipe_z:
		_spawn_pipe(_last_pipe_z)
		_last_pipe_z -= 3.0


var cpt = 0
func _spawn_pipe(pipe_z: float) -> void:
	var pipe = pipe_scene.instantiate()
	# Randomly set pipe color to RED or BLUE
	pipe.pipe_color = randi() % 8
	pipe.pipe_color = cpt % 8
	pipe.pipe_color = cpt % 8
	cpt += 1
	pipe.position.x -= 6.0
	#var direction = randi() % 2
	#if direction == 0:
	#	pipe.position.x -= 6.0
	#else:
	#	pipe.position.x += 6.0
	#	pipe.rotation.y = PI
	get_parent().add_child(pipe)  # Add to scene tree first
	# Now set global position after it's in the tree
	pipe.global_position.z = pipe_z
	# Add pipe to list
	_pipes.append(pipe)
	# Remove oldest pipe if list contains 3 or more
	if _pipes.size() > 20:
		var old_pipe = _pipes.pop_front()
		old_pipe.queue_free()
