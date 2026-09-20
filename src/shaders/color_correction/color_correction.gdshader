shader_type canvas_item;

// https://en.wikipedia.org/wiki/Rec._709
const vec4 luma_coeffs_709 = vec4(0.2126, 0.7152, 0.0722, 0.0);
// https://en.wikipedia.org/wiki/Rec._2020
const vec4 luma_coeffs_2020 = vec4(0.2627, 0.6780, 0.0593, 0.0);

const vec3 eulers_constant = vec3(0.57735);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear; // _nearest
uniform float gamma = 1.0;
uniform float brightness = 0.0;
uniform float contrast = 0.0;
uniform float saturation = 1.0;
uniform float hue = 0.0;
uniform int luminosity_coefficient_standard = 0;
uniform float radial_bias = 0.0;
uniform float radial_min_distance = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 col = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	if (abs(radial_bias) <= 0.001) {
		if (abs(hue) > 0.001) {
			vec3 proj = eulers_constant * dot(eulers_constant, col.rgb);
			vec3 u = col.rgb - proj;
			vec3 v = cross(eulers_constant, u);
			col = vec4(u*cos(hue) + v*sin(hue) + proj, col.a);
		}
		if (abs(saturation - 1.0) > 0.001) {
			switch (luminosity_coefficient_standard) {
				case 0: {
					vec4 lum = vec4(dot(col, luma_coeffs_2020));
					col = clamp(mix(lum, col, saturation), vec4(0.0), vec4(1.0, 1.0, 1.0, 1.0));
					break;
				}
				case 1: {
					vec4 lum = vec4(dot(col, luma_coeffs_709));
					col = clamp(mix(lum, col, saturation), vec4(0.0), vec4(1.0, 1.0, 1.0, 1.0));
					break;
				}
			}
		}
		if (abs(contrast - 1.0) > 0.001) {
			vec4 df = col - vec4(0.5, 0.5, 0.5, 1.0);
			col += df * (contrast - 1.0);
		}
		col += vec4(vec3(brightness), 1.0);
		col *= vec4(vec3(gamma), 1.0);
	} else {
		vec2 uv_diff = (vec2(0.5) - SCREEN_UV);
		float uv_len;
		if (radial_bias < 0.0) {
			uv_len = max(1.0 - length(uv_diff) - radial_min_distance, 0.0);
		} else {
			uv_len = max(length(uv_diff) - radial_min_distance, 0.0);
		}
		uv_len = (uv_len - 0.5)*abs(radial_bias)*2.0 + 1.0;
		if (abs(hue) > 0.001) {
			vec3 proj = eulers_constant * dot(eulers_constant, col.rgb);
			vec3 u = col.rgb - proj;
			vec3 v = cross(eulers_constant, u);
			col = vec4(u*cos(hue*uv_len) + v*sin(hue*uv_len) + proj, col.a);
		}
		if (abs(saturation - 1.0) > 0.001) {
			switch (luminosity_coefficient_standard) {
				case 0: {
					vec4 lum = vec4(dot(col, luma_coeffs_2020));
					col = clamp(mix(lum, col, (saturation-1.0)*uv_len + 1.0), vec4(0.0), vec4(1.0, 1.0, 1.0, 1.0));
					break;
				}
				case 1: {
					vec4 lum = vec4(dot(col, luma_coeffs_709));
					col = clamp(mix(lum, col, (saturation-1.0)*uv_len + 1.0), vec4(0.0), vec4(1.0, 1.0, 1.0, 1.0));
					break;
				}
			}
		}
		if (abs(contrast - 1.0) > 0.001) {
			vec4 df = col - vec4(0.5, 0.5, 0.5, 1.0);
			col += df * (contrast - 1.0)*uv_len;
		}
		col += vec4(vec3(brightness*uv_len), 1.0);
		col *= vec4(vec3((gamma-1.0)*uv_len + 1.0), 1.0);
	}
	
	COLOR = col;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
