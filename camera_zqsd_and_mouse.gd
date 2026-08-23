extends Camera3D

## Node to keep centered in view. Defaults to the sibling node named "player".
@export var target_path: NodePath

## How quickly the camera catches up to the target's Z position.
## Higher values feel snappier, lower values feel "heavier" (more inertia).
## The default converges ~95% of the distance within about 10 physics
## frames (at 60 fps), matching the player's per-tile movement duration,
## so the camera stays smooth without ever falling noticeably behind.
@export var smoothing_speed: float = 3.0

var _target: Node3D
var _z_offset: float


func _ready() -> void:
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
	var weight := 1.0 - exp(-smoothing_speed * delta)
	global_position.z = lerp(global_position.z, target_z, weight)
