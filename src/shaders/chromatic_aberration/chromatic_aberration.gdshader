shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear; // _nearest
uniform vec2 velocity_r;
uniform vec2 velocity_g;
uniform vec2 velocity_b;
uniform float radial_bias = 0.0;
uniform float radial_min_distance = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 col;
	if (abs(radial_bias) <= 0.001) {
		col = vec4(
			textureLod(screen_texture, SCREEN_UV + velocity_r, 0.0).r,
			textureLod(screen_texture, SCREEN_UV + velocity_g, 0.0).g,
			textureLod(screen_texture, SCREEN_UV + velocity_b, 0.0).b,
			textureLod(screen_texture, SCREEN_UV, 0.0).a
		);
	} else {
		vec2 uv_diff = (vec2(0.5) - SCREEN_UV);
		float uv_len;
		if (radial_bias < 0.0) {
			uv_len = max(1.0 - length(uv_diff) - radial_min_distance, 0.0);
		} else {
			uv_len = max(length(uv_diff) - radial_min_distance, 0.0);
		}
		uv_len = (uv_len - 0.5)*abs(radial_bias)*2.0 + 1.0;
		col = vec4(
			textureLod(screen_texture, SCREEN_UV + velocity_r*uv_len, 0.0).r,
			textureLod(screen_texture, SCREEN_UV + velocity_g*uv_len, 0.0).g,
			textureLod(screen_texture, SCREEN_UV + velocity_b*uv_len, 0.0).b,
			textureLod(screen_texture, SCREEN_UV, 0.0).a
		);
	}
	
	
	COLOR = col;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
