#ifndef CUSTOMFUNCTIONNODE_FASTNOISE
#define CUSTOMFUNCTIONNODE_FASTNOISE

#include "../Shaders/Includes/Fast Noise.hlsl"

void OpenSimplex2_float(int seed, float3 position, float frequency, out float output) {
  fnl_state noise = fnlCreateState();
  noise.noise_type = FNL_NOISE_OPENSIMPLEX2;
  noise.frequency = frequency;
  noise.seed = seed;

  output = fnlGetNoise3D(noise, position.x, position.y, position.z) * 0.5 + 0.5;
}
void OpenSimplex2_float(int seed, float3 position, float frequency, int octaves, out float output) {
  fnl_state noise = fnlCreateState();
  noise.noise_type = FNL_NOISE_OPENSIMPLEX2;
  noise.frequency = frequency;
  noise.seed = seed;
  noise.fractal_type = FNL_FRACTAL_FBM;
  noise.octaves = octaves;

  output = fnlGetNoise3D(noise, position.x, position.y, position.z) * 0.5 + 0.5;
}

void Perlin_float(int seed, float3 position, float frequency, out float output) {
  fnl_state noise = fnlCreateState();
  noise.noise_type = FNL_NOISE_PERLIN;
  noise.frequency = frequency;
  noise.seed = seed;

  output = fnlGetNoise3D(noise, position.x, position.y, position.z) * 0.5 + 0.5;
}
void Perlin_float(int seed, float3 position, float frequency, int octaves, out float output) {
  fnl_state noise = fnlCreateState();
  noise.noise_type = FNL_NOISE_PERLIN;
  noise.frequency = frequency;
  noise.seed = seed;
  noise.fractal_type = FNL_FRACTAL_FBM;
  noise.octaves = octaves;

  output = fnlGetNoise3D(noise, position.x, position.y, position.z) * 0.5 + 0.5;
}

void Voronoi_float(int seed, float3 position, float frequency, out float output) {
  fnl_state noise = fnlCreateState();
  noise.noise_type = FNL_NOISE_CELLULAR;
  noise.frequency = frequency;
  noise.seed = seed;
  noise.cellular_distance_func = FNL_CELLULAR_DISTANCE_EUCLIDEAN;
  
  output = fnlGetNoise3D(noise, position.x, position.y, position.z) * 0.5 + 0.5;
}

#endif
