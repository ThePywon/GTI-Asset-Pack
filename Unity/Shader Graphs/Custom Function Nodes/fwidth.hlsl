#ifndef CUSTOMFUNCTIONNODE_FWIDTH
#define CUSTOMFUNCTIONNODE_FWIDTH

void fwidth_float(float Input, out float Output) {
  Output = abs(ddx(Input)) + abs(ddy(Input));
}

void fwidth_float(float2 Input, out float2 Output) {
  Output = abs(ddx(Input)) + abs(ddy(Input));
}

void fwidth_float(float3 Input, out float3 Output) {
  Output = abs(ddx(Input)) + abs(ddy(Input));
}

#endif
