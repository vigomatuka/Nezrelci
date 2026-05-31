## LimboOverlay3D.gd
## Prikvači na CanvasLayer node (layer = 10).
## Djeca: ColorRect (puni ekran) — opcionalno s limbo_blend.gdshader materijalom.
##
## Scena struktura:
##   LimboOverlay (CanvasLayer, layer=10)
##   └── Panel (ColorRect, full-screen)

extends CanvasLayer

@onready var panel: ColorRect = $Panel

const COLOR_IN  := Color(0.2, 0.1, 0.4, 0.0)    # početak — prozirno
const COLOR_MID := Color(0.15, 0.05, 0.3, 0.85)  # sredina — tamno ljubičasto
const COLOR_OUT := Color(0.0, 0.2, 0.1, 0.0)     # kraj — prozirno zelenkasto


func _ready() -> void:
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.color = Color.TRANSPARENT
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	LimboManager.limbo_started.connect(_on_started)
	LimboManager.limbo_progress.connect(_on_progress)
	LimboManager.limbo_ended.connect(_on_ended)


func _on_started(_duration: float) -> void:
	panel.color = COLOR_IN


func _on_progress(t: float) -> void:
	var alpha_curve: float = sin(t * PI)

	var col: Color
	if t < 0.5:
		col = COLOR_IN.lerp(COLOR_MID, t * 2.0)
	else:
		col = COLOR_MID.lerp(COLOR_OUT, (t - 0.5) * 2.0)

	col.a = alpha_curve * 0.85
	panel.color = col

	if panel.material is ShaderMaterial:
		panel.material.set_shader_parameter("limbo_t", t)
		panel.material.set_shader_parameter("glitch_strength", sin(t * PI) * 0.6)


func _on_ended() -> void:
	panel.color = Color.TRANSPARENT
