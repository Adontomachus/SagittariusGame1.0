shader_type canvas_item;

uniform float reveal_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 indicator_color : source_color = vec4(0.8, 0.2, 0.2, 1.0);
uniform float glow_width : hint_range(0.0, 0.2) = 0.05;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float wave = sin(UV.x * 12.0) * 0.03;
	float threshold = UV.y + wave;
	float reveal_line = 1.0 - reveal_progress;

	if (threshold < reveal_line) {
		discard;
	}

	float edge_glow = smoothstep(reveal_line + glow_width, reveal_line, threshold);
	vec4 glow = vec4(indicator_color.rgb * 2.0, 1.0) * edge_glow;

	COLOR = tex + glow;
}