extends Area3D
class_name Creature

const move_distance := 1.0
var move_frames := 60
var jump_height := 1.0

var _frame := 0
var _start_pos := position
var _direction : Direction
var _direction_history: Array

enum Direction { NONE, UP, DOWN, LEFT, RIGHT }

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

func _move_step() -> void:

	_frame += 1
	# Gestion rotation
	var prev_rotation = direction_rotations[_direction_history[-2]]
	var target_rotation = direction_rotations[_direction]
	var delta_angle := wrapf(target_rotation - prev_rotation, -PI, PI)
	var rotation_step = delta_angle / move_frames
	rotation.y += rotation_step
	rotation.y = wrapf(rotation.y, 0.0, TAU)

	# Gestion movement
	var dist_per_frame = move_distance / move_frames
	position += direction_vectors[_direction] * dist_per_frame

	# Gestion saut
	var step_size := float(_frame) / move_frames
	# trajectoire parabolique
	var jump = jump_height * step_size * (1.0 - step_size)
	position.y = _start_pos.y + jump
	position = position.snapped(Vector3.ONE * 0.001)


func explode_animation() -> void:
	var explosion = GPUParticles3D.new()
	explosion.amount = 500
	explosion.lifetime = 2.0
	explosion.one_shot = true
	explosion.explosiveness = 1.0

	# ✅ Use a mesh for particles (works on all versions)
	var mesh = SphereMesh.new()
	mesh.radius = 0.1
	mesh.height = 0.1
	explosion.draw_pass_1 = mesh

	var material = ParticleProcessMaterial.new()  # Or ParticleProcessMaterial
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 0.8
	material.spread = 180.0
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	material.gravity = Vector3(0, -9.8, 0)
	material.damping_min = 2.0
	material.damping_max = 4.0

	# Color ramp for fade effect
	var color_ramp = Gradient.new()
	color_ramp.colors = [
		Color(1.0, 0.9, 0.2, 1.0),
		Color(1.0, 0.5, 0.0, 1.0),
		Color(1.0, 0.1, 0.0, 0.8),
		Color(1.0, 0.0, 0.0, 0.0)
	]
	material.color_ramp = color_ramp

	explosion.process_material = material
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	explosion.emitting = true
