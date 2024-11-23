shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_SAMPLER: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NIGHT_VISION_EFFECT;


void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 screen_texture = texture(SCREEN_SAMPLER, uv);
	vec3 screen_color = screen_texture.rgb;
	vec3 color = texture(NIGHT_VISION_EFFECT, vec2(0,0)).rgb;
	
	screen_color *= color;
	
	ALBEDO = (screen_color.rgb);
}