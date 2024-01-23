shader_type spatial;

const float step = 0.05;
const float width = 0.005;
const vec3 grey_color = vec3(0.1, 0.1, 0.1);
const vec3 brown_color = vec3(0.4, 0.4, 0.4);

void fragment() {
    float mod_x = mod(UV.x, step);
    float mod_y = mod(UV.y, step);

    if (mod_x < width || mod_y < width) {
      ALBEDO = grey_color;
    } else {
      ALBEDO = brown_color;
    }
}
