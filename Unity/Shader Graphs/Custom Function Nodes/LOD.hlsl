#ifndef CUSTOMFUNCTIONNODE_LOD
#define CUSTOMFUNCTIONNODE_LOD

float get_var_factor(float3 Input) {
  float3 fwidth = abs(ddx(Input)) + abs(ddy(Input));
  return max(max(fwidth.x, fwidth.y), fwidth.z);
}

void LOD_float(float3 position, float limit0, out int lod) {
  float var_factor = get_var_factor(position);

  if (var_factor <= limit0) lod = 0;
  else lod = 1;
}
void LOD_float(float3 position, float limit0, float limit1, out int lod) {
  float var_factor = get_var_factor(position);

  if (var_factor <= limit0) lod = 0;
  else if (var_factor <= limit1) lod = 1;
  else lod = 2;
}
void LOD_float(float3 position, float limit0, float limit1, float limit2, out int lod) {
  float var_factor = get_var_factor(position);

  if (var_factor <= limit0) lod = 0;
  else if (var_factor <= limit1) lod = 1;
  else if (var_factor <= limit2) lod = 2;
  else lod = 3;
}
void LOD_float(float3 position, float limit0, float limit1, float limit2, float limit3, out int lod) {
  float var_factor = get_var_factor(position);

  if (var_factor <= limit0) lod = 0;
  else if (var_factor <= limit1) lod = 1;
  else if (var_factor <= limit2) lod = 2;
  else if (var_factor <= limit3) lod = 3;
  else lod = 4;
}
void LOD_float(float3 position, float limit0, float limit1, float limit2, float limit3, float limit4, out int lod) {
  float var_factor = get_var_factor(position);

  if (var_factor <= limit0) lod = 0;
  else if (var_factor <= limit1) lod = 1;
  else if (var_factor <= limit2) lod = 2;
  else if (var_factor <= limit3) lod = 3;
  else if (var_factor <= limit4) lod = 4;
  else lod = 5;
}
void LOD_float(float3 position, float limit0, float limit1, float limit2, float limit3, float limit4, float limit5, out int lod) {
  float var_factor = get_var_factor(position);

  if (var_factor <= limit0) lod = 0;
  else if (var_factor <= limit1) lod = 1;
  else if (var_factor <= limit2) lod = 2;
  else if (var_factor <= limit3) lod = 3;
  else if (var_factor <= limit4) lod = 4;
  else if (var_factor <= limit5) lod = 5;
  else lod = 6;
}
void LOD_float(float3 position, float limit0, float limit1, float limit2, float limit3, float limit4, float limit5, float limit6, out int lod) {
  float var_factor = get_var_factor(position);

  if (var_factor <= limit0) lod = 0;
  else if (var_factor <= limit1) lod = 1;
  else if (var_factor <= limit2) lod = 2;
  else if (var_factor <= limit3) lod = 3;
  else if (var_factor <= limit4) lod = 4;
  else if (var_factor <= limit5) lod = 5;
  else if (var_factor <= limit6) lod = 6;
  else lod = 7;
}
void LOD_float(float3 position, float limit0, float limit1, float limit2, float limit3, float limit4, float limit5, float limit6, float limit7, out int lod) {
  float var_factor = get_var_factor(position);

  if (var_factor <= limit0) lod = 0;
  else if (var_factor <= limit1) lod = 1;
  else if (var_factor <= limit2) lod = 2;
  else if (var_factor <= limit3) lod = 3;
  else if (var_factor <= limit4) lod = 4;
  else if (var_factor <= limit5) lod = 5;
  else if (var_factor <= limit6) lod = 6;
  else if (var_factor <= limit7) lod = 7;
  else lod = 8;
}

#endif
