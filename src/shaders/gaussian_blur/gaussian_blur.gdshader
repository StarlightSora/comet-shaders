shader_type canvas_item;

const int cache_size = 64;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear; // _nearest
uniform ivec2 screen_size = ivec2(640, 360);
uniform float stdev;
uniform bool y_direction;
uniform float gcache[cache_size];
uniform int sample_size;
uniform float downsample;

float gauss(int d) {
	if (d < cache_size) {
		return gcache[d];
	} else {
		return 0.0; // Optimized away //exp(-float(d*d)/(2.0 * stdev * stdev) ) / sqrt(2.0 * PI * stdev * stdev);
	}
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
		vec4 col = textureLod(screen_texture, SCREEN_UV, 0.0) * gzero;
		float acu = gzero;
		float safe_downsample = max(0.001, downsample);
		if (!y_direction) {
			for (int dx = 1; dx <= sample_size; dx += 1) {
				float weight = gauss(dx);
				col += textureLod(screen_texture, SCREEN_UV + (vec2(float(dx)*safe_downsample, 0.0) / vec2(screen_size)), 0.0) * weight;
				col += textureLod(screen_texture, SCREEN_UV + (vec2(float(-dx)*safe_downsample, 0.0) / vec2(screen_size)), 0.0) * weight;
				acu += weight + weight;
			}
		} else {
			for (int dy = 1; dy <= sample_size; dy += 1) {
				float weight = gauss(dy);
				col += textureLod(screen_texture, SCREEN_UV + (vec2(0.0, float(dy)*safe_downsample) / vec2(screen_size)), 0.0) * weight;
				col += textureLod(screen_texture, SCREEN_UV + (vec2(0.0, float(-dy)*safe_downsample) / vec2(screen_size)), 0.0) * weight;
				acu += weight + weight;
			}
		}
		
		COLOR = col / acu;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
