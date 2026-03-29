shader_type canvas_item;

uniform float speed = 0.02;
uniform sampler2D screen_texture: hint_screen_texture;
uniform vec4 water_color: source_color;
uniform vec4 rim_color: source_color;
uniform sampler2D wave_noise: repeat_enable;

void fragment() {
    vec2 water_wave = (texture(wave_noise, UV + TIME * speed).rg - 0.5) * 0.02;
    vec2 uv = vec2(SCREEN_UV.x, SCREEN_UV.y - UV.y) + water_wave;
    vec4 color = texture(screen_texture, uv);

    float mix_value = 0.5 - UV.y;
    float avg_color = (color.r + color.g + color.b) / 3.0;
    avg_color = pow(avg_color, 1.4);
    mix_value += avg_color;
    mix_value = clamp(mix_value, 0.0, 0.7);

    vec4 base_water = mix(water_color, color, mix_value);

    float rim_factor = smoothstep(-0.1, 0.05, UV.y);
    vec4 rim = rim_color;
    rim.a = 0.5;

    vec4 final_color = mix(rim, base_water, rim_factor);
    COLOR = final_color;
}
