shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear; // _nearest
uniform vec4 tint : source_color = vec4(1.0);
uniform float radial_bias = 0.0;
uniform float radial_min_distance = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (abs(radial_bias) <= 0.001) {
		COLOR = textureLod(screen_texture, SCREEN_UV, 0.0) * tint;
	} else {
		vec2 uv_diff = (vec2(0.5) - SCREEN_UV);
		float uv_len;
		if (radial_bias < 0.0) {
			uv_len = max(1.0 - length(uv_diff) - radial_min_distance, 0.0);
		} else {
			uv_len = max(length(uv_diff) - radial_min_distance, 0.0);
		}
		uv_len = (uv_len - 0.5)*abs(radial_bias)*2.0 + 1.0;
		COLOR = textureLod(screen_texture, SCREEN_UV, 0.0) * mix(vec4(1.0), tint, uv_len);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
