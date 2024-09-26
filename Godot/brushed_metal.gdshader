shader_type spatial;
#include "include/FastNoiseLite.gdshaderinc"

varying vec3 local_pos;
void vertex() {
	vec3 scale = vec3(length(MODEL_MATRIX[0]),
	length(MODEL_MATRIX[1]), length(MODEL_MATRIX[2]));
	local_pos = VERTEX * scale;
}

const int detail_octaves = 4;

const float EPSILON = 0.0001;

uniform vec3 color_a : source_color = vec3(0.675);
uniform vec3 color_b : source_color = vec3(0.647);
uniform int base_noise_seed = 1337;
uniform float base_noise_frequency : hint_range(0.01, 10.0, 0.01) = 8.0;
uniform int smoothness_noise_seed = 1338;
uniform float smoothness_noise_frequency : hint_range(0.01, 10.0, 0.01) = 1.5;
uniform float smoothness_noise_strength : hint_range(0.01, 1.0, 0.01) = 0.15;
uniform float base_smoothness : hint_range(0.01, 0.75, 0.01) = 0.25;
uniform int bump_noise_seed = 1337;
uniform float bump_noise_frequency : hint_range(0.01, 10.0, 0.01) = 1.5;
uniform float bump_strength : hint_range(0.01, 10.0, 0.01) = 1.25;
uniform float metallic : hint_range(0.01, 1.0, 0.01) = 1.0;

void fragment() {
	// Get LOD
	vec3 pos_fwidth = fwidth(local_pos);
	float var_factor = max(max(pos_fwidth.x, pos_fwidth.y), pos_fwidth.z);
	int LOD;
	if(var_factor <= 0.005) LOD = 0;
	else if(var_factor <= 0.015) LOD = 1;
	else if(var_factor <= 0.03) LOD = 2;
	else LOD = 3;

	fnl_state base_noise = fnlCreateState(base_noise_seed);
	base_noise.noise_type = FNL_NOISE_OPENSIMPLEX2;
	base_noise.frequency = base_noise_frequency;

	float base_noise_value = fnlGetNoise3D(base_noise, UV.x, UV.y * 200.0, 0.0);

	ALBEDO = mix(color_a, color_b, base_noise_value);


	fnl_state smoothness_noise = fnlCreateState(smoothness_noise_seed);
	smoothness_noise.noise_type = FNL_NOISE_PERLIN;
	smoothness_noise.frequency = smoothness_noise_frequency;
	smoothness_noise.fractal_type = FNL_FRACTAL_FBM;
	smoothness_noise.octaves = detail_octaves - LOD;

	float smoothness_noise_value = fnlGetNoise3D(smoothness_noise, local_pos.x, local_pos.y, local_pos.z);

	ROUGHNESS = (1.0-clamp(smoothness_noise_value * smoothness_noise_strength + 0.25, 0, 1)) - base_smoothness;


	METALLIC = metallic;


	fnl_state bump_noise = fnlCreateState(bump_noise_seed);
	bump_noise.noise_type = FNL_NOISE_PERLIN;
	bump_noise.frequency = bump_noise_frequency;
	bump_noise.fractal_type = FNL_FRACTAL_FBM;
	bump_noise.octaves = detail_octaves - LOD;

	float bump_noise_value = fnlGetNoise3D(bump_noise, local_pos.x, local_pos.y, local_pos.z);

	float bump = bump_noise_value * bump_strength * 0.01;

	vec3 scale = vec3(length(MODEL_MATRIX[0]),
		length(MODEL_MATRIX[1]), length(MODEL_MATRIX[2]));
	vec3 normal = mat3(INV_VIEW_MATRIX) * NORMAL;
	bool smooth_normals = any(greaterThan(fwidth(NORMAL), vec3(EPSILON)));
	vec3 n_pos = (smooth_normals ? normal * scale : local_pos) + bump * normal;

	vec3 cross_ = normalize(cross(dFdy(n_pos), dFdx(n_pos)));
	mat3 TangentMatrix = transpose(mat3(TANGENT, BINORMAL, NORMAL));
	vec3 final_normal = TangentMatrix * mat3(VIEW_MATRIX) * cross_;
	NORMAL_MAP = final_normal * 0.5 + vec3(0.5);
}
