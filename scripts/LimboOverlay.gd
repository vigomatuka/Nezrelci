## LimboOverlay.gd
## Stavi na CanvasLayer node (layer = 10 ili više da bude iznad svega).
## Djeca: ColorRect (za fade), ShaderMaterial na njemu za glitch efekt.
##
## Scena struktura:
##   LimboOverlay (CanvasLayer)
##   └── Panel (ColorRect, full-screen)
##       └── ShaderMaterial → limbo_blend.gdshader

extends CanvasLayer

@onready var panel: ColorRect = $Panel

# Boje za fade (možeš promijeniti)
const COLOR_LIMBO_IN  := Color(0.2, 0.1, 0.4, 0.0)   # početak — prozirno
const COLOR_LIMBO_MID := Color(0.15, 0.05, 0.3, 0.85) # sredina — tamno ljubičasto
const COLOR_LIMBO_OUT := Color(0.0, 0.2, 0.1, 0.0)    # kraj — prozirno zelenkasto


func _ready() -> void:
	# Panel treba pokriti cijeli ekran
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.color = Color.TRANSPARENT
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Povežise na LimboManager
	LimboManager.limbo_progress.connect(_on_progress)
	LimboManager.limbo_started.connect(_on_started)
	LimboManager.limbo_ended.connect(_on_ended)


func _on_started(_duration: float) -> void:
	panel.color = COLOR_LIMBO_IN


func _on_progress(t: float) -> void:
	# Fade in pa fade out — vrhunac na t=0.5
	var alpha_curve := sin(t * PI)   # 0 → 1 → 0

	# Interpoliraj boju
	var col: Color
	if t < 0.5:
		col = COLOR_LIMBO_IN.lerp(COLOR_LIMBO_MID, t * 2.0)
	else:
		col = COLOR_LIMBO_MID.lerp(COLOR_LIMBO_OUT, (t - 0.5) * 2.0)

	col.a = alpha_curve * 0.85
	panel.color = col

	# Proslijedi t shaderu ako postoji
	if panel.material is ShaderMaterial:
		panel.material.set_shader_parameter("limbo_t", t)
		panel.material.set_shader_parameter("glitch_strength", sin(t * PI) * 0.6)


func _on_ended() -> void:
	panel.color = Color.TRANSPARENT
