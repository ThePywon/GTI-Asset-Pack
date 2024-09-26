shader_type spatial;
render_mode world_vertex_coords;
#include "include/FastNoiseLite.gdshaderinc"

uniform bool use_local = false;

varying vec3 local_pos;
void vertex() {
	if(use_local) {
	vec3 scale = vec3(length(MODEL_MATRIX[0]),
		length(MODEL_MATRIX[1]), length(MODEL_MATRIX[2]));
		local_pos = mat3(inverse(MODEL_MATRIX)) * (VERTEX - NODE_POSITION_WORLD) * scale;
	} else {
		local_pos = VERTEX;
	}
}

const int base_noise_octaves = 8;
const int indents_noise_octaves = 9;
const int lines_noise_octaves = 2;

const float EPSILON = 0.0001;

uniform int base_noise_seed = 1337;
uniform float base_noise_frequency : hint_range(0.01, 5.0, 0.01) = 0.75;
uniform vec4 inside_color : source_color = vec4(0.506, 0.514, 0.549, 1.0);
uniform vec4 outside_color : source_color = vec4(0.553, 0.592, 0.608, 1.0);
uniform float color_mix_offset : hint_range(0.01, 1.0, 0.01) = 0.8;

uniform int indents_noise_seed = 1338;
uniform float indents_noise_frequency : hint_range(0.01, 5.0, 0.01) = 0.65;
uniform float indents_threshold : hint_range(0.01, 0.5, 0.01) = 0.2;
uniform float indents_bump_strength : hint_range(0.01, 20.0, 0.01) = 3.65;
uniform float global_bump_strength : hint_range(0.01, 20.0, 0.01) = 4.0;

uniform float seams_pattern_size : hint_range(0.01, 0.5, 0.01) = 0.02;
uniform float seams_strength : hint_range(0.01, 1.0, 0.01) = 0.3;

uniform int pores_noise_seed = 1337;
uniform float pores_noise_frequency : hint_range(0.01, 250.0, 0.01) = 90;
uniform float pores_threshold : hint_range(0.01, 0.5, 0.01) = 0.05;
uniform float pores_bump_strength : hint_range(0.01, 1.0, 0.01) = 0.35;

uniform int lines_noise_seed = 1337;
uniform float lines_noise_frequency : hint_range(0.01, 100.0, 0.01) = 10;
uniform float lines_width : hint_range(0.0, 1.0, 0.01) = 0.25;
uniform float lines_distance : hint_range(1.0, 10.0, 0.01) = 3.0;
uniform float lines_sharpness : hint_range(1.0, 20.0, 0.01) = 6.5;
uniform vec2 lines_offset = vec2(0);
uniform float lines_bump_strength : hint_range(0.01, 5.0, 0.01) = 1.0;

void fragment() {
	// Get LOD
	vec3 pos_fwidth = fwidth(local_pos);
	float var_factor = max(max(pos_fwidth.x, pos_fwidth.y), pos_fwidth.z);
	int LOD;
	if(var_factor <= 0.001) LOD = 0;
	else if(var_factor <= 0.005) LOD = 1;
	else if(var_factor <= 0.015) LOD = 2;
	else if(var_factor <= 0.03) LOD = 3;
	else if(var_factor <= 0.05) LOD = 4;
	else LOD = 5;

	// Noises definition
	fnl_state base_noise = fnlCreateState(base_noise_seed);
	base_noise.noise_type = FNL_NOISE_PERLIN;
	base_noise.frequency = base_noise_frequency;
	base_noise.fractal_type = FNL_FRACTAL_FBM;

	fnl_state indents_noise = fnlCreateState(indents_noise_seed);
	indents_noise.noise_type = FNL_NOISE_PERLIN;
	indents_noise.frequency = indents_noise_frequency;
	indents_noise.fractal_type = FNL_FRACTAL_FBM;

	fnl_state lines_noise = fnlCreateState(lines_noise_seed);
	lines_noise.noise_type = FNL_NOISE_OPENSIMPLEX2;
	lines_noise.frequency = lines_noise_frequency;
	lines_noise.fractal_type = FNL_FRACTAL_FBM;

	base_noise.octaves = base_noise_octaves - LOD;
	indents_noise.octaves = indents_noise_octaves - LOD;
	lines_noise.octaves = LOD <= 2 ? lines_noise_octaves : lines_noise_octaves - 1;

	float base_value = fnlGetNoise3D(base_noise, local_pos.x, local_pos.y, local_pos.z);
	float indents_value = fnlGetNoise3D(indents_noise, local_pos.x, local_pos.y, local_pos.z) - indents_threshold;
	float lines_value = fnlGetNoise3D(lines_noise, local_pos.x, local_pos.y, local_pos.z);


	// FIRST PASS
	// Mixing some noise
	float indents_step = step(0.0, indents_value);
	float seams = distance(fract(UV.y / seams_pattern_size), 0.5);
	float base_mix = (base_value - (indents_value * indents_step * indents_bump_strength));
	float seams_mix = base_mix - (seams * seams_strength * (1.0-indents_step));


	// SECOND PASS
	// Adding lines
	float step_x = distance(0.5,
	fract((local_pos.x - lines_offset.x) /
	lines_distance + EPSILON)) -
	(0.5 - 1.0 / (lines_distance * 2.0)) -
	(0.5-lines_width*0.5) / lines_distance;
	float final_step_x = clamp(step_x * 2.0, 0, 1) * lines_sharpness;

	float step_z = distance(0.5,
	fract((local_pos.z - lines_offset.y) /
	lines_distance + EPSILON)) -
	(0.5 - 1.0 / (lines_distance * 2.0)) -
	(0.5-lines_width*0.5) / lines_distance;
	float final_step_z = clamp(step_z * 2.0, 0, 1) * lines_sharpness;

	float lines_step = clamp(final_step_x + final_step_z, 0, 1);
	float color_value = seams_mix + (1.0-clamp(indents_value * 16.0, 0, 1)) *
	lines_step * (lines_value + 1.0) * lines_bump_strength * 0.5;


	ALBEDO = mix(inside_color, outside_color, clamp(color_value + color_mix_offset, 0, 1)).rgb;


	// THIRD PASS
	// Normal map
	float pores_value;
	float pores_step;
	if(LOD < 2) {
		fnl_state pores_noise = fnlCreateState(pores_noise_seed);
		pores_noise.noise_type = FNL_NOISE_CELLULAR;
		pores_noise.frequency = pores_noise_frequency;

		pores_value = fnlGetNoise3D(pores_noise, local_pos.x, local_pos.y, local_pos.z) + 1.0;

		pores_step = 1.0-step(pores_threshold, pores_value);
	}

	float bump =

	base_mix * global_bump_strength * 0.01

	- (LOD < 2 ? ((1.0-pores_value) - (1.0-pores_threshold)) * pores_step *
	(1.0-clamp(indents_value * 128.0, 0, 1)) *
	(1.0-clamp(lines_step * 3.0, 0, 1)) * pores_bump_strength * 0.01 : 0.0)

	+ lines_value * lines_step *
	(1.0-clamp(indents_value * 16.0, 0, 1)) *
	lines_bump_strength * 0.01;

	vec3 scale = vec3(length(MODEL_MATRIX[0]),
		length(MODEL_MATRIX[1]), length(MODEL_MATRIX[2]));
	vec3 vertex = mat3(INV_VIEW_MATRIX) * VERTEX;
	vec3 normal = mat3(INV_VIEW_MATRIX) * NORMAL;
	bool smooth_normals = any(greaterThan(fwidth(NORMAL), vec3(EPSILON)));
	vec3 n_pos = (smooth_normals ? normal * scale : vertex) + bump * normal;

	vec3 cross_ = normalize(cross(dFdy(n_pos), dFdx(n_pos)));
	mat3 TangentMatrix = transpose(mat3(TANGENT, BINORMAL, NORMAL));
	vec3 final_normal = TangentMatrix * mat3(VIEW_MATRIX) * cross_;
	NORMAL_MAP = final_normal * 0.5 + vec3(0.5);
}
