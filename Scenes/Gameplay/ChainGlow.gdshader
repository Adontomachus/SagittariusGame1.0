shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.4, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	float vignette = smoothstep(0.3, 0.75, dist);
	COLOR = vec4(glow_color.rgb, vignette * intensity * glow_color.a);
}