shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear; // _nearest
uniform float stdev = 0.0;
uniform float min_distance = 0.0;
uniform float dynamic_downsample_target = 4.0;
uniform ivec2 screen_size = ivec2(640, 360);
uniform bool inverted_blur_strength = false;
uniform float relative_blur_angle = 0.0;
uniform bool bidirectional = false;

float gauss_sd(float d, float sd) {
	return exp(-d*d/(2.0 * sd * sd) ) / sqrt(2.0 * PI * sd * sd);
}
float get_static_samplesize(float sd) {
	return ceil(sd * 2.5); // should be 3.0 but optimized away
}
int get_sample_size(float sd) {
	return min(int(ceil(dynamic_downsample_target * sqrt(get_static_samplesize(sd)))), 64);
}
float dyn_downsample(float sd) {
	return sd * 2.5 / dynamic_downsample_target / sqrt(get_static_samplesize(sd));
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (stdev <= 0.001) {
		COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	} else {
		vec2 uv_diff = (vec2(0.5) - SCREEN_UV);
		if (abs(relative_blur_angle) >= 0.001) {
			uv_diff *= mat2(vec2(cos(relative_blur_angle), -sin(relative_blur_angle)), vec2(sin(relative_blur_angle), cos(relative_blur_angle)));
		}
		float uv_len;
		if (inverted_blur_strength) {
			uv_len = max(1.0 - length(uv_diff) - min_distance, 0.0);
		} else {
			uv_len = max(length(uv_diff) - min_distance, 0.0);
		}
		float effective_sd = stdev * uv_len * 2.0;
		float gzero = gauss_sd(0.0, effective_sd);
		float acu = gzero;
		int sample_size = get_sample_size(effective_sd);
		vec4 col = textureLod(screen_texture, SCREEN_UV, 0.0) * gzero;
		for (int d = 1; d <= sample_size; d++) {
			float adjusted_dx = float(d)*dyn_downsample(effective_sd);
			float weight = gauss_sd(adjusted_dx, effective_sd);
			col += textureLod(screen_texture, SCREEN_UV + (vec2(uv_diff) * adjusted_dx / vec2(screen_size)), 0.0) * weight;
			acu += weight;
			if (bidirectional) {
				col += textureLod(screen_texture, SCREEN_UV - (vec2(uv_diff) * adjusted_dx / vec2(screen_size)), 0.0) * weight;
			acu += weight;
			}
		}
		
		COLOR = col / acu;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
