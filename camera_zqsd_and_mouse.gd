extends Camera3D

@export var move_speed : float = 5.0
@export var mouse_sensitivity : float = 0.002

func _ready():
	return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	# Mouse look
	return
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, -1.57, 1.57)


func _process(delta):
	# Using built-in UI actions (ZQSD works by default with these)
	var input_dir := Vector3(
		Input.get_axis("LEFT", "RIGHT"),    # A/D or Q/D
		0,
		Input.get_axis("UP", "DOWN")        # W/Z and S
	)
	
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		var forward = -global_transform.basis.z
		var right = global_transform.basis.x
		var direction = (forward * -input_dir.z + right * input_dir.x).normalized()
		global_translate(direction * move_speed * delta)
