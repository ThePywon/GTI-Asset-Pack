shader_type spatial;
render_mode world_vertex_coords;
#include "include/FastNoiseLite.gdshaderinc"

uniform bool use_local = true;

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

const float EPSILON = 0.0001;

uniform int base_noise_seed = 1337;
uniform float base_noise_frequency : hint_range(0.01, 10.0, 0.01) = 5.0;
uniform vec4 inside_color : source_color = vec4(0.639, 0.524, 0.164, 1.0);
uniform vec4 outside_color : source_color = vec4(0.635, 0.593, 0.275, 1.0);
uniform float color_mix_offset : hint_range(0.01, 1.0, 0.01) = 0.8;

uniform int holes_noise_seed = 1337;
uniform float holes_noise_frequency : hint_range(0.01, 20.0, 0.01) = 8.0;
uniform float holes_threshold : hint_range(0.01, 0.5, 0.01) = 0.15;
uniform float holes_bump_strength : hint_range(0.01, 10.0, 0.01) = 6.0;

uniform float global_bump_strength : hint_range(0.01, 5.0, 0.01) = 1.5;
uniform float smoothness : hint_range(0.01, 0.5, 0.01) = 0.15;

void fragment() {
	fnl_state base_noise = fnlCreateState(base_noise_seed);
	base_noise.noise_type = FNL_NOISE_PERLIN;
	base_noise.frequency = base_noise_frequency;
	
	fnl_state holes_noise = fnlCreateState(holes_noise_seed);
	holes_noise.noise_type = FNL_NOISE_CELLULAR;
	holes_noise.frequency = holes_noise_frequency;
	
	float base_value = fnlGetNoise3D(base_noise, local_pos.x, local_pos.y, local_pos.z);
	float holes_value = fnlGetNoise3D(holes_noise, local_pos.x, local_pos.y, local_pos.z) + 1.0;
	
	
	float holes_step = 1.0-step(holes_threshold, holes_value);
	
	float final_holes_value = ((1.0-holes_value)-(1.0-holes_threshold)) * holes_step * holes_bump_strength * 10.0;
	
	ALBEDO = mix(inside_color, outside_color, clamp(base_value + color_mix_offset - clamp(final_holes_value, 0, 1), 0, 1)).rgb;
	
	
	ROUGHNESS = 1.0 - (base_value - clamp(final_holes_value, 0, 1)) - smoothness;
	
	
	float bump = (base_value - (final_holes_value - (1.0-holes_threshold)) *
	holes_bump_strength * 0.01) * global_bump_strength * 0.01;
	
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
