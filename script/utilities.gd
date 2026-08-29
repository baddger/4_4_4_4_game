class_name Utilities



static func explode_animation(global_position) -> void:

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

	var tree = Engine.get_main_loop()
	tree.current_scene.add_child(explosion)
	explosion.global_position = global_position
	explosion.emitting = true
