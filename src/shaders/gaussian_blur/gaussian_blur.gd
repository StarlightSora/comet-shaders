@tool
class_name GaussianBlurScreenShader
extends Control

## The layer property of the underlying CanvasLayers. This controls the draw order.
@export var layer: int = 1:
	set(u):
		layer = u
		if Engine.is_editor_hint() or loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).get_parent().layer = u
			node_of(ScreenShaderGlobals.PassLayer.SECOND).get_parent().layer = u
## The reference screen resolution.
##
## Note that this does not *have* to be exact with the actual screen resolution.
## It will up/downsample accordingly. It is recommended to set this at 50% or 75% of the output resolution of your game.
##
## Lower resolutions perform better,
## as you need lower stdev values for the same visual blur amount, but quality is reduced.
@export var screen_size: Vector2i = Vector2i(640, 360):
	set(u):
		screen_size = u
		if Engine.is_editor_hint() or loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("screen_size", u)
			node_of(ScreenShaderGlobals.PassLayer.SECOND).material.set_shader_parameter("screen_size", u)
## The standard deviation component of the gaussian blur. In laymen's terms, this is the intensity of the blur.
@export_range(0.0, 64.0, 0.5) var stdev: float = 8.0:
	set(u):
		stdev = u
		if Engine.is_editor_hint() or loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("stdev", u)
			node_of(ScreenShaderGlobals.PassLayer.SECOND).material.set_shader_parameter("stdev", u)
			recalc_blur_cache()
## Calculated gaussian blurs weights below this threshold
## will be treated as 0.0 and be ignored from the blur calculation.
@export_range(0.0001, 1.0, 0.00005, "exp") var min_weight: float = 0.0025:
	set(u):
		min_weight = u
		if Engine.is_editor_hint() or loaded:
			recalc_blur_cache()
## true if using dynamic downsampling, otherwise static downsampling.
@export var dynamic_downsampling: bool = true:
	set(u):
		dynamic_downsampling = u
		if Engine.is_editor_hint() or loaded:
			recalc_blur_cache()
## Static downsample factor. Higher values downsample more. Values below 1.0 will upsample.
@export_range(0.2, 32.0, 0.1, "exp") var static_downsample: float = 1.0:
	set(u):
		static_downsample = u
		if Engine.is_editor_hint() or loaded:
			recalc_blur_cache()
## The target count of how many samples to take for dynamic downsampling. Higher values downsample less.
@export_range(1, 24, 0.5, "prefer_slider", "exp") var dynamic_downsample_target: float = 6:
	set(u):
		dynamic_downsample_target = u
		if Engine.is_editor_hint() or loaded:
			recalc_blur_cache()
## The dynamic_downsample_target will be multiplied by stdev^this_property.
@export_range(0.0, 1.0, 0.01) var dynamic_downsample_strong_compensation: float = 0.5:
	set(u):
		dynamic_downsample_strong_compensation = u
		if Engine.is_editor_hint() or loaded:
			recalc_blur_cache()
## The minimum downsample factor.
## Higher values produce lower quality at low stdev, but perform slightly better.
@export_range(0.1, 8.0, 0.1, "exp") var dynamic_downsample_min: float = 0.5:
	set(u):
		dynamic_downsample_min = u
		if Engine.is_editor_hint() or loaded:
			recalc_blur_cache()
## If the cache overflow warning should be suppressed.
@export var ignore_cache_overflow_warning: bool = false

var loaded: bool = false
var sample_size: int = 0
var gcache: Array[float] = []

func get_dyn_downsample() -> float:
	sample_size = ceili(stdev * 3.0)
	if dynamic_downsampling:
		return max(dynamic_downsample_min, float(sample_size)/dynamic_downsample_target) \
			/ pow(sample_size, dynamic_downsample_strong_compensation)
	else:
		return max(0.001, static_downsample)

func recalc_blur_cache() -> void:
	var safe_downsample: float = get_dyn_downsample()
	gcache.clear()
	gcache.resize(ScreenShaderGlobals.CACHE_SIZE_MAX)
	for d in range(ScreenShaderGlobals.CACHE_SIZE_MAX):
		var g := gaussf(d*min(safe_downsample, 1.0))
		gcache[d] = g
		if (g <= min_weight) or (d > sample_size):
			sample_size = d
			break
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("gcache", gcache)
	node_of(ScreenShaderGlobals.PassLayer.SECOND).material.set_shader_parameter("gcache", gcache)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("sample_size", sample_size)
	node_of(ScreenShaderGlobals.PassLayer.SECOND).material.set_shader_parameter("sample_size", sample_size)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("downsample", safe_downsample)
	node_of(ScreenShaderGlobals.PassLayer.SECOND).material.set_shader_parameter("downsample", safe_downsample)
	if sample_size > ScreenShaderGlobals.CACHE_SIZE_MAX and not ignore_cache_overflow_warning:
		push_warning("sample_size is calculated to be bigger than " + str(ScreenShaderGlobals.CACHE_SIZE_MAX) + ", the resulting blur\
 will be clamped! Consider increasing static_downsample or decreasing dynamic_downsample_strong_compensation!")

func gaussf(df: float) -> float:
	if stdev <= 0.001:
		return 1.0
	else:
		return exp(-df*df / (2.0*stdev*stdev)) / sqrt(2.0*PI*stdev*stdev)

@onready var pass1 = $Pass1/ColorRect
@onready var pass2 = $Pass2/ColorRect
func node_of(pass_layer: ScreenShaderGlobals.PassLayer) -> ColorRect:
	if Engine.is_editor_hint():
		match pass_layer:
			ScreenShaderGlobals.PassLayer.FIRST:
				return self.get_node(^"Pass1/ColorRect")
			ScreenShaderGlobals.PassLayer.SECOND:
				return self.get_node(^"Pass2/ColorRect")
	else:
		match pass_layer:
			ScreenShaderGlobals.PassLayer.FIRST:
				return pass1
			ScreenShaderGlobals.PassLayer.SECOND:
				return pass2
	push_error("Unreachable code!")
	return null

func _ready() -> void:
	if not Engine.is_editor_hint():
		node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("screen_size", screen_size)
		node_of(ScreenShaderGlobals.PassLayer.SECOND).material.set_shader_parameter("screen_size", screen_size)
		node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("stdev", stdev)
		node_of(ScreenShaderGlobals.PassLayer.SECOND).material.set_shader_parameter("stdev", stdev)
		node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("downsample", get_dyn_downsample())
		node_of(ScreenShaderGlobals.PassLayer.SECOND).material.set_shader_parameter("downsample", get_dyn_downsample())
		node_of(ScreenShaderGlobals.PassLayer.FIRST).get_parent().layer = layer
		node_of(ScreenShaderGlobals.PassLayer.SECOND).get_parent().layer = layer
		recalc_blur_cache()
		loaded = true
