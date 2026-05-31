extends Node3D

@onready var _bar: ProgressBar = $SubViewport/ProgressBar

func set_health(current: float, maximum: float) -> void:
	_bar.max_value = maximum
	_bar.value = current
	_update_color(current / maximum)

func _update_color(ratio: float) -> void:
	var color := Color.GREEN.lerp(Color.RED, 1.0 - ratio)
	_bar.get_theme_stylebox("fill", "ProgressBar").bg_color = color
