shader_type canvas_item;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	float radius = 0.5;
	float edge = 0.005;

	float alpha = 1.0 - smoothstep(radius - edge, radius + edge, dist);
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= alpha;
}