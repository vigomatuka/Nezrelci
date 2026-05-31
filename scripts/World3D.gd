extends Node3D

func _ready() -> void:
	LimboManager.register_world(self)
