#ifndef CUSTOMFUNCTIONNODE_CELLULARNOISE
#define CUSTOMFUNCTIONNODE_CELLULARNOISE

#ifndef INCLUDE_FASTNOISE
#define INCLUDE_FASTNOISE
#include "Includes/Fast Noise.hlsl"
#endif

void CellularNoise3D_float(int seed, float3 position, float frequency, int octaves, out float output) {
  fnl_state noise = fnlCreateState(seed);
  noise.noise_type = FNL_NOISE_CELLULAR;
  noise.frequency = frequency;
  noise.cellular_distance_func = FNL_CELLULAR_DISTANCE_EUCLIDEAN;
  noise.fractal_type = FNL_FRACTAL_FBM;
  noise.octaves = octaves;
  
  output = fnlGetNoise3D(noise, position.x, position.y, position.z) * 0.5 + 0.5;
}
void CellularNoise2D_float(int seed, float2 position, float frequency, int octaves, out float output) {
  fnl_state noise = fnlCreateState(seed);
  noise.noise_type = FNL_NOISE_CELLULAR;
  noise.frequency = frequency;
  noise.cellular_distance_func = FNL_CELLULAR_DISTANCE_EUCLIDEAN;
  noise.fractal_type = FNL_FRACTAL_FBM;
  noise.octaves = octaves;
  
  output = fnlGetNoise2D(noise, position.x, position.y) * 0.5 + 0.5;
}

#endif
