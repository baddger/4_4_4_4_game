extends Camera3D

## Node to keep centered in view. Defaults to the sibling node named "player".
@export var target_path: NodePath

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


func _physics_process(_delta: float) -> void:
	if _target:
		global_position.z = _target.global_position.z + _z_offset
