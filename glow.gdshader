shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float trail_persistence : hint_range(0.9, 0.99) = 0.96;
uniform float glow_strength : hint_range(0.0, 2.0) = 0.5;

void fragment() {
    vec3 col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    
    // Apply trail fade
    col *= trail_persistence;
    
    // Simple glow
    vec2 texel_size = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));
    vec3 glow = vec3(0.0);
    for(float x = -1.0; x <= 1.0; x++) {
        for(float y = -1.0; y <= 1.0; y++) {
            glow += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(x, y) * texel_size).rgb;
        }
    }
    glow /= 9.0;
    
    col += glow * glow_strength;
    
    COLOR = vec4(col, 1.0);
}