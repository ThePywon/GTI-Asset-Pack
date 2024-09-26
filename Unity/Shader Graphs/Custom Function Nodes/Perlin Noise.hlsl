#ifndef CUSTOMFUNCTIONNODE_PERLINNOISE
#define CUSTOMFUNCTIONNODE_PERLINNOISE

#ifndef INCLUDE_FASTNOISE
#define INCLUDE_FASTNOISE
#include "Includes/Fast Noise.hlsl"
#endif


void PerlinNoise3D_float(int seed, float3 position, float frequency, int octaves, out float output) {
  fnl_state noise = fnlCreateState(seed);
  noise.noise_type = FNL_NOISE_PERLIN;
  noise.frequency = frequency;
  noise.fractal_type = FNL_FRACTAL_FBM;
  noise.octaves = octaves;

  output = fnlGetNoise3D(noise, position.x, position.y, position.z) * 0.5 + 0.5;
}

void PerlinNoise2D_float(int seed, float2 position, float frequency, int octaves, out float output) {
  fnl_state noise = fnlCreateState(seed);
  noise.noise_type = FNL_NOISE_PERLIN;
  noise.frequency = frequency;
  noise.fractal_type = FNL_FRACTAL_FBM;
  noise.octaves = octaves;

  output = fnlGetNoise2D(noise, position.x, position.y) * 0.5 + 0.5;
}

#endif
