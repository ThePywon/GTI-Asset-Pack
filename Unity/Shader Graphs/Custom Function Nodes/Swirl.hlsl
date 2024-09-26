#ifndef CUSTOMFUNCTIONNODE_SWIRL
#define CUSTOMFUNCTIONNODE_SWIRL

void Swirl_float(float2 position, float intensity, int swirls, float max_swirl_dist, out float3 color) {
  float angle = atan2(-position.y, position.x) * 0.1;
  float len = min(length(position), max_swirl_dist);

  color = float3(0, 0, 0);
  color += sin(len * intensity * 10 + angle * swirls * 10);
}

#endif
