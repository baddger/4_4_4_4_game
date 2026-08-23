extends Camera3D
## Free-look camera controlled with ZQSD (AZERTY-style WASD) + mouse.
##
## - Move: UP / DOWN / LEFT / RIGHT input actions (bound to Z/S/Q/D by default)
## - Sprint: hold Shift
## - Look: move the mouse while it's captured
## - Toggle mouse capture: Escape (release) / left click (re-capture)

@export var move_speed: float = 5.0
@export var sprint_multiplier: float = 2.5
@export var mouse_sensitivity: float = 0.002
@export var min_pitch_deg: float = -89.0
@export var max_pitch_deg: float = 89.0

var _min_pitch: float
var _max_pitch: float


func _ready() -> void:
	_min_pitch = deg_to_rad(min_pitch_deg)
	_max_pitch = deg_to_rad(max_pitch_deg)
	_capture_mouse()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_release_mouse()
		return

	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			_capture_mouse()
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_apply_look(event.relative)


func _physics_process(delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis("LEFT", "RIGHT"),
		Input.get_axis("UP", "DOWN")
	)

	if input_dir == Vector2.ZERO:
		return

	input_dir = input_dir.normalized()

	var forward := -global_transform.basis.z
	var right := global_transform.basis.x
	var direction := (right * input_dir.x + forward * -input_dir.y).normalized()

	var speed := move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= sprint_multiplier

	global_translate(direction * speed * delta)


func _apply_look(mouse_delta: Vector2) -> void:
	rotation.y -= mouse_delta.x * mouse_sensitivity
	rotation.x -= mouse_delta.y * mouse_sensitivity
	rotation.x = clamp(rotation.x, _min_pitch, _max_pitch)


func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
