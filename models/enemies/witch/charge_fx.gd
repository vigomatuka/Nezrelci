extends GPUParticles3D

func _ready() -> void:
	emitting = false
	amount = 60
	lifetime = 0.7
	local_coords = true

	var qm := QuadMesh.new()
	qm.size = Vector2(0.08, 0.08)
	draw_pass_1 = qm

	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 0.6
	pm.initial_velocity_min = 0.0
	pm.initial_velocity_max = 0.0
	pm.radial_accel_min = -4.0
	pm.radial_accel_max = -6.0
	pm.gravity = Vector3.ZERO
	pm.scale_min = 0.3
	pm.scale_max = 1.0
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.5, 0.85, 1.0, 1.0))
	ramp.add_point(0.8, Color(0.7, 0.95, 1.0, 1.0))
	ramp.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var gtex := GradientTexture1D.new(); gtex.gradient = ramp
	pm.color_ramp = gtex
	process_material = pm

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.vertex_color_use_as_albedo = true
	mat.emission_enabled = true
	mat.emission = Color(0.4, 0.8, 1.0)
	mat.emission_energy_multiplier = 4.0
	qm.material = mat

func start() -> void:
	restart()
	emitting = true

func stop() -> void:
	emitting = false
