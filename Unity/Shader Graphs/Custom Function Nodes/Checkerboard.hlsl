#ifndef CUSTOMFUNCTIONNODE_CHECKERBOARD
#define CUSTOMFUNCTIONNODE_CHECKERBOARD

void Checkerboard_float(float3 position, float size, out bool output) {
  float3 tile = round(position / size + 0.50001);
  float checkerboard = tile.x + tile.y + tile.z;
  output = frac(checkerboard * 0.5) * 2;
}

#endif
