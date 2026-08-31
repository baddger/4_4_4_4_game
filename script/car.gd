extends Creature
class_name Car

enum PipeColor { RED, BLUE, GREEN, YELLOW, PURPLE, BROWN, WHITE, BLACK }

@export var pipe_color: PipeColor = PipeColor.BLUE

const material_blue = preload("res://frog_car/material_car_blue.tres")
const material_red = preload("res://frog_car/material_car_red.tres")
const material_white = preload("res://frog_car/material_car_white.tres")
const material_green = preload("res://frog_car/material_car_green.tres")
const material_purple = preload("res://frog_car/material_car_purple.tres")
const material_yellow = preload("res://frog_car/material_car_yellow.tres")
const material_brown = preload("res://frog_car/material_car_brown.tres")
const material_black = preload("res://frog_car/material_car_black.tres")

const red_sequence = [st8.RIGHT]
const blue_sequence = [st8.RIGHT, st8.NONE]
const green_sequence = [st8.RIGHT]
const yellow_sequence = [st8.RIGHT, st8.NONE]
const purple_sequence = [st8.RIGHT]
const brown_sequence = [st8.RIGHT, st8.NONE]
const white_sequence = [st8.RIGHT, st8.RIGHT, st8.NONE]
const black_sequence = [st8.RIGHT]

var move_frames = 30
var jump_height = 0.0


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
	if pipe_color == PipeColor.GREEN :
		_state_sequence = green_sequence
		mesh_node.set_surface_override_material(0, material_green)
	if pipe_color == PipeColor.YELLOW :
		_state_sequence = yellow_sequence
		mesh_node.set_surface_override_material(0, material_yellow)
	if pipe_color == PipeColor.PURPLE :
		move_frames = 20
		_state_sequence = purple_sequence
		mesh_node.set_surface_override_material(0, material_purple)
	if pipe_color == PipeColor.BROWN :
		move_frames = 15
		_state_sequence = brown_sequence
		mesh_node.set_surface_override_material(0, material_brown)
	if pipe_color == PipeColor.WHITE :
		move_frames = 15
		_state_sequence = white_sequence
		mesh_node.set_surface_override_material(0, material_white)
	if pipe_color == PipeColor.BLACK :
		move_frames = 13
		_state_sequence = black_sequence
		mesh_node.set_surface_override_material(0, material_black)


	rotation.y = direction_rotations[_state_sequence[0]]
	set_state(_state_sequence[0])
	next_in_sequence()

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


	_move_step(move_frames, jump_height)

	if _frame >= move_frames:
		_frame = 0
		next_in_sequence()


func next_in_sequence():
	_sequence_index = (_sequence_index) % _state_sequence.size()
	var state = _state_sequence[_sequence_index]
	set_state(state)
	_sequence_index += 1
