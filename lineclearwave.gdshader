shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float amplitude : hint_range(0.0, 1.0) = 0.0;
uniform float frequency : hint_range(1.0, 50.0) = 8.0;
uniform float speed : hint_range(0.0, 50.0) = 4.0;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
    vec2 uv = SCREEN_UV;
    float dist = distance(uv, center);
    float wave = sin(dist * frequency - TIME * speed) * amplitude * 0.01;
    vec2 direction = normalize(uv - center);
    uv += direction * wave;
    COLOR = texture(SCREEN_TEXTURE, uv);
}