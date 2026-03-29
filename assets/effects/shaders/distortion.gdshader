shader_type canvas_item;

uniform float speed = 0.02;
uniform sampler2D screen_texture: hint_screen_texture;
uniform sampler2D wave_noise: repeat_enable;

void fragment() {
    vec2 water_wave = (texture(wave_noise, UV + TIME * speed).rg - 0.5) * 0.02;
    vec2 uv = SCREEN_UV + water_wave;
    vec4 color = texture(screen_texture, uv);
	
    COLOR = color;
}
