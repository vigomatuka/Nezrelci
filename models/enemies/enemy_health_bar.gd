extends Node3D

@onready var _bar: ProgressBar = $SubViewport/ProgressBar

func set_health(current: float, maximum: float) -> void:
	_bar.max_value = maximum
	_bar.value = current
