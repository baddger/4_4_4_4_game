extends Area3D
class_name Creature

const move_distance := 1.0

var _frame := 0
var _start_pos := position
var _direction : Direction
var _state_history: Array
var _position_history: Array
var _rotation_history: Array

enum Direction { NONE, UP, DOWN, LEFT, RIGHT, BACKFLIP }

const direction_vectors := {
	Direction.UP: Vector3.FORWARD,
	Direction.DOWN: Vector3.BACK,
	Direction.LEFT: Vector3.LEFT,
	Direction.RIGHT: Vector3.RIGHT,
}

const direction_rotations := {
	Direction.DOWN:  0,
	Direction.RIGHT: 0.5 * PI,
	Direction.UP:    1.0 * PI,
	Direction.LEFT:  1.5 * PI,
}

const INPUT_TO_DIRECTION := {
	"ui_up": Direction.UP,
	"ui_down": Direction.DOWN,
	"ui_left": Direction.LEFT,
	"ui_right": Direction.RIGHT,
}

func get_last_valid_direction(indice  : int) -> Direction:
	"""Retrieve the last direction in history that is not NONE or BACKFLIP."""
	for i in range(_state_history.size() - 1, -1, -1):
		var direction = _state_history[i]
		if direction != Direction.NONE and direction != Direction.BACKFLIP:
			if indice == 0 :
				return direction
			else :
				indice -= 1
	return Direction.NONE

func _move_step_back(move_frames : int, jump_height: float) -> void:
	_frame += 1

	# Gestion movement
	var dist_per_frame = direction_vectors[get_last_valid_direction(0)] * (move_distance / move_frames)
	var dist = _frame * dist_per_frame
	position = _position_history[-1] +  dist
	position = position.snapped(Vector3.ONE * 0.001)

		# Gestion rotation
	var prev_rotation = direction_rotations[get_last_valid_direction(1)]
	var target_rotation = direction_rotations[get_last_valid_direction(0)]
	var delta_angle := wrapf(target_rotation - prev_rotation, -PI, PI)
	var rotation_step = delta_angle / move_frames
	rotation.y += rotation_step
	rotation.y = wrapf(rotation.y, 0.0, TAU)
	pass


func _move_step(move_frames : int, jump_height: float) -> void:

	_frame += 1
	# Gestion rotation
	var prev_rotation = direction_rotations[get_last_valid_direction(1)]
	var target_rotation = direction_rotations[get_last_valid_direction(0)]
	var delta_angle := wrapf(target_rotation - prev_rotation, -PI, PI)
	var rotation_step = delta_angle / move_frames
	rotation.y += rotation_step
	rotation.y = wrapf(rotation.y, 0.0, TAU)

	# Gestion movement
	var dist_per_frame = direction_vectors[get_last_valid_direction(0)] * (move_distance / move_frames)
	var dist = _frame * dist_per_frame
	position = _position_history[-1] +  dist

	# Gestion saut
	var step_size := float(_frame) / move_frames
	# trajectoire parabolique
	var jump = jump_height * step_size * (1.0 - step_size)
	position.y = _start_pos.y + jump
	position = position.snapped(Vector3.ONE * 0.001)

func set_sate(state) :
	_state_history.append(state)
	_position_history.append(position)
	_rotation_history.append(rotation)

func explode_animation() -> void:

	# GPUParticles3D
	var explosion = GPUParticles3D.new()
	explosion.amount = 500
	explosion.lifetime = 2.0
	explosion.one_shot = true
	explosion.explosiveness = 1.0

	# SphereMesh
	var mesh = SphereMesh.new()
	mesh.radius = 0.1
	mesh.height = 0.1
	var mesh_material = StandardMaterial3D.new()
	mesh_material.albedo_color = Color.RED
	mesh.material = mesh_material

	explosion.draw_pass_1 = mesh

	# ParticleProcessMaterial
	var material = ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.8
	material.spread = 180.0
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	material.gravity = Vector3(0, -9.8, 0)
	material.damping_min = 2.0
	material.damping_max = 4.0

	explosion.process_material = material

	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	explosion.emitting = true
