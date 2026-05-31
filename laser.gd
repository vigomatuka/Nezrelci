extends Node3D

@onready var _beam: MeshInstance3D = $MeshInstance3D
@onready var _ray: RayCast3D = $RayCast3D

func fire(from: Vector3, dir: Vector3, max_len := 30.0) -> void:
	global_position = from
	look_at(from + dir)                 # -Z now points along the beam
	_ray.target_position = Vector3(0, 0, -max_len)
	_ray.force_raycast_update()

	var dist := max_len
	if _ray.is_colliding():
		dist = from.distance_to(_ray.get_collision_point())
		var hit := _ray.get_collider()
		if hit and hit.has_method("take_damage"):
			hit.take_damage(20)

	# stretch the cylinder to reach the hit point
	_beam.mesh.height = dist
	_beam.position = Vector3(0, 0, -dist / 2.0)
	_beam.rotation_degrees.x = -90      # lay the cylinder along -Z (flip to 90 if it looks wrong)

	# show briefly then fade
	visible = true
	await get_tree().create_timer(0.25).timeout
	visible = false
