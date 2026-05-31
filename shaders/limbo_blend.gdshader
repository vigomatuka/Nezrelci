// limbo_blend.gdshader
// Stavi kao ShaderMaterial na ColorRect u LimboOverlay.
// Dodaje scan-line i glitch efekt za vrijeme limbo tranzicije.

shader_type canvas_item;

uniform float limbo_t : hint_range(0.0, 1.0) = 0.0;
uniform float glitch_strength : hint_range(0.0, 1.0) = 0.0;

// Jednostavni hash za šum
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float t = limbo_t;
	float active = sin(t * 3.14159);  // 0→1→0 kroz tranziciju

	// --- Scan linije ---
	float scan = sin(uv.y * 120.0 + TIME * 3.0) * 0.03 * active;
	
	// --- Horizontalni glitch ---
	float glitch_band = step(0.97, hash(vec2(floor(uv.y * 20.0), floor(TIME * 8.0))));
	float glitch_offset = (hash(vec2(uv.y, TIME)) - 0.5) * glitch_strength * 0.04 * glitch_band;
	uv.x += glitch_offset;

	// --- Vignette na rubovima ---
	float vignette = (1.0 - uv.x * 2.0 + 1.0) * (1.0 - uv.y * 2.0 + 1.0);
	// Samo na krajevima ekrana
	float edge_v = 1.0 - smoothstep(0.0, 0.15, uv.x) * smoothstep(1.0, 0.85, uv.x)
	                   * smoothstep(0.0, 0.1, uv.y) * smoothstep(1.0, 0.9, uv.y);

	// --- Chromatic aberration u sredini tranzicije ---
	float aberr = active * 0.004;
	vec4 col = COLOR;
	col.r += texture(TEXTURE, vec2(uv.x + aberr, uv.y)).r * 0.3;
	col.b += texture(TEXTURE, vec2(uv.x - aberr, uv.y)).b * 0.3;

	// Primijeni scan linije i vignette
	col.rgb -= scan;
	col.rgb -= edge_v * 0.4 * active;
	col.a *= active;

	COLOR = col;
}
