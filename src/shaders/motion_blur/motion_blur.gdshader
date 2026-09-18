shader_type canvas_item;

const int cache_size = 64;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear; // _nearest
uniform ivec2 screen_size;
uniform float stdev;
uniform vec2 direction;
uniform int sample_size;
uniform float downsample;
uniform bool bidirectional;

float gauss(float d) {
	return exp(-d*d/(2.0 * stdev * stdev) ) / sqrt(2.0 * PI * stdev * stdev);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (stdev < 0.001) {
		COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	} else {
		float gzero = gauss(0);
		//int sample_size = int(3.0*stdev);
		vec4 col = textureLod(screen_texture, SCREEN_UV, 0.0) * gzero;
		float acu = gzero;
		for (int i = 1; i <= min(sample_size, cache_size); i++) {
			float d = float(i) * downsample;
			float weight = gauss(float(d));
			col += textureLod(screen_texture, SCREEN_UV + (vec2(direction) * float(d) / vec2(screen_size)), 0.0) * weight;
			if (bidirectional) {
				col += textureLod(screen_texture, SCREEN_UV + (-vec2(direction) * float(d) / vec2(screen_size)), 0.0) * weight;
				acu += weight;
			}
			acu += weight;
		}
		COLOR = col / acu;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
