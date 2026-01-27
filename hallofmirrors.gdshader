shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float persistence : hint_range(0.9, 0.999) = 0.99;

void fragment() {
    vec3 previous_frame = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    COLOR = vec4(previous_frame * persistence, 1.0);
}