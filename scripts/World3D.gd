extends Node3D

@export var player_scene: PackedScene

func _ready() -> void:
	LimboManager.register_world(self)

	var existing := get_tree().get_first_node_in_group("Player")
	if existing == null and player_scene != null:
		var p := player_scene.instantiate()
		add_child(p)
		var spawn := find_child("SpawnDefault", true, false) as Node3D
		if spawn:
			p.global_position = spawn.global_position
