shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;
uniform float trail_strength : hint_range(0.0, 1.0) = 0.95;
uniform float zoom : hint_range(0.95, 1.05) = 0.995;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // zoom towards center
    vec2 dir = uv - center;
    uv = center + dir * zoom;
    
    // sample previous frame
    vec4 prev = texture(SCREEN_TEXTURE, uv);
    
    // blend with trail
    COLOR = vec4(prev.rgb * trail_strength, 1.0);
}