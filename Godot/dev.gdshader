shader_type spatial;

uniform float pattern_size : hint_range(0.1, 10.0, 0.1) = 0.5;
uniform vec3 offset = vec3(0);

const float EPSILON = 0.00001;

varying vec3 local_pos;
void vertex() {
	vec3 scale = vec3(length(MODEL_MATRIX[0]),
		length(MODEL_MATRIX[1]), length(MODEL_MATRIX[2]));
	local_pos = VERTEX / pattern_size * scale + offset + EPSILON;
}

uniform vec3 color_a : source_color = vec3(0.5);
uniform vec3 color_b : source_color = vec3(0.35);
uniform vec3 color_c : source_color = vec3(0.2);

float checkerboard(vec3 position) {
	vec3 tile = round(position + vec3(0.5));
	float combined = tile.x + tile.y + tile.z;
	return fract(combined * 0.5) * 2.0;
}

void fragment() {
	float main_checkerboard = checkerboard(local_pos);
	float big_checkerboard = checkerboard(local_pos * vec3(0.05));
	vec3 mix_a = mix(color_a, color_b, main_checkerboard);
	vec3 mix_b = mix(color_c, color_b, main_checkerboard);
	ALBEDO = mix(mix_a, mix_b, big_checkerboard);
}
