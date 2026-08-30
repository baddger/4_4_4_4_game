extends Node3D

## Node to keep centered in view. Defaults to the sibling node named "player".
@export var target_path: NodePath
var _target: Node3D
var _size = 44
var _z_offset: float

func _ready() -> void:
	if target_path.is_empty():
		_target = get_parent().get_node_or_null("Camera3D")
	else:
		_target = get_node_or_null(target_path)

	if _target:
		# + 3 a cause du tilt de la camera qui fait que l'on regarde un peu plus vers l'avant
		_z_offset =  _target.global_position.z
	else:
		push_warning("ground: no camera found to follow.")

func _physics_process(_delta: float) -> void:
	if not _target:
		return

	var target_z := _target.global_position.z - _z_offset
	var diff := target_z - global_position.z

	if diff > _size:
		global_position.z += _size*2
	if diff < -(_size):
		global_position.z -= _size*2
