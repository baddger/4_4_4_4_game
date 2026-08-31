extends Creature
class_name Car

enum PipeColor { BLUE, RED }
@export var pipe_color: PipeColor = PipeColor.BLUE

const material_blue = preload("res://frog_car/material_car_blue.tres")
const material_red = preload("res://frog_car/material_car_red.tres")

const blue_sequence = [st8.RIGHT, st8.NONE, st8.RIGHT]
const red_sequence = [st8.RIGHT]

var _state_sequence: Array
var _sequence_index := 0

func _ready() -> void:
	var mesh_node = get_node("frog/frog_paint_texture_0")
	if pipe_color == PipeColor.BLUE :
		_state_sequence = blue_sequence
		mesh_node.set_surface_override_material(0, material_blue)
	if pipe_color == PipeColor.RED :
		_state_sequence = red_sequence
		mesh_node.set_surface_override_material(0, material_red)

	set_state(_state_sequence[0])
	next_in_sequence()
	rotation.y = direction_rotations[_state_history[0]]

	area_entered.connect(_on_area_entered)

func _on_area_entered(_area: Area3D) -> void:
	if _area.name.contains("portal_to_death"):
		portal = _area
		await get_tree().create_timer(3.0).timeout
		queue_free()



func _physics_process(_delta: float) -> void:

	if portal :
		translation_to_death(global_position, portal.global_position)
		return

	# hors limite
	if abs(position.x) > 20 or abs(position.y) > 20:
		queue_free()
		return

	var move_frames = 30
	var jump_height = 0.0
	_move_step(move_frames, jump_height)

	if _frame >= move_frames:
		_frame = 0
		next_in_sequence()


func next_in_sequence():
	_sequence_index = (_sequence_index) % _state_sequence.size()
	var state = _state_sequence[_sequence_index]
	set_state(state)
	_sequence_index += 1
