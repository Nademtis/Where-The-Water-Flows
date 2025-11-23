shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_enable;

uniform sampler2D noise_texture: filter_nearest, repeat_enable;

uniform float distortion = 0.005;
uniform float wave_strenth = 0.01; //0.01
uniform vec2 speed = vec2(0.5, 0.2);
uniform float blend_factor = 1; // 0 = only texture, 1 = fully blended with screen

// Called for every vertex the material is visible on.
void vertex() {
	VERTEX.y += sin(TIME);
}
	// Called for every pixel the material is visible on.
void fragment() {
	vec2 uv = UV + speed * TIME;
	vec2 noise = 2.0 * texture(noise_texture, uv).rg - vec2(1.0);
	COLOR = texture(TEXTURE, UV + noise * wave_strenth); //Sample Water texture

	vec4 base_color = texture(TEXTURE, UV + noise * wave_strenth);
    vec4 screen_color = texture(screen_texture, SCREEN_UV + noise * distortion);

	//COLOR *= texture(screen_texture, SCREEN_UV + noise * distortion);
	COLOR = mix(base_color, base_color * screen_color, blend_factor);
}
