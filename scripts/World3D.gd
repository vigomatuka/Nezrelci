## World3D.gd
## Prikvači na root node svake scene (Node3D).
## Registrira scenu u LimboManageru i spawnira igrača ako ga već nema.

extends Node3D

## Povuci Player.tscn ovdje u Inspectoru
@export var player_scene: PackedScene

func _ready() -> void:
	LimboManager.register_world(self)

	# Spawnaj igrača samo ako već nije u sceni
	# (pri teleportu, igrač dolazi zajedno s tranzicijom)
	var existing := get_tree().get_first_node_in_group("Player")
	if existing == null and player_scene != null:
		var p := player_scene.instantiate()
		add_child(p)
		var spawn := find_child("SpawnDefault", true, false) as Node3D
		if spawn:
			p.global_position = spawn.global_position
