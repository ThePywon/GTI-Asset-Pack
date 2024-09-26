#ifndef CUSTOMFUNCTIONNODE_LED
#define CUSTOMFUNCTIONNODE_LED

void LED_float(float2 uv, out bool filter) {
  bool vertical = step(0.7, frac(uv.x));
  bool horizontal = step(0.1, frac(uv.y));

  filter = vertical && horizontal;
}

#endif
