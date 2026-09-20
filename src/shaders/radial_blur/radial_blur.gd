@tool
extends Control
## Radial blur. Edges of the screen will be blurred much more than the center.
##
## The blur direction defaults to outward relative to the center.
##
## For radial gaussian blur, use two RadialBlur instances, with the relative blur angles perpendicular to each other.
##
## Time complexity per pixel: O(n), however n is clamped to be 64 maximum (n is small).
## 
## Does not cache weights.

## The layer property of the underlying CanvasLayers. This controls the draw order.
@export var layer: int = 1:
	set(u):
		layer = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).get_parent().layer = u
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
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("screen_size", u)
## The standard deviation component of the motion blur. In laymen's terms, this is the intensity of the blur.
@export_range(0.0, 64.0, 0.5) var stdev: float = 16.0:
	set(u):
		stdev = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("stdev", u)
## Minimum distance from the center for the blur to start taking effect.
@export_range(-1.0, 1.0, 0.01) var min_distance: float = 0.0:
	set(u):
		min_distance = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("min_distance", u)
## true if the center should be the blurrier part, not the edges.
@export var inverted_blur_strength: bool = false:
	set(u):
		inverted_blur_strength = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("inverted_blur_strength", u)
## true if radial blur also applies to the opposite direction.
@export var bidirectional: bool = false:
	set(u):
		bidirectional = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("bidirectional", u)
## Direction of the blur, relative to the center. 0 indicates it will blur outward.
@export_range(0.0, 360.0, 1.0, "radians_as_degrees") var relative_blur_angle: float = 0.0:
	set(u):
		relative_blur_angle = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("relative_blur_angle", u)
## The target count of how many samples to take for dynamic downsampling. Higher values downsample less.
@export_range(0.5, 8, 0.5, "prefer_slider", "exp") var dynamic_downsample_target: float = 3.0:
	set(u):
		dynamic_downsample_target = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("dynamic_downsample_target", u)

var loaded: bool = false

@onready var pass1 = $Pass1/ColorRect
func node_of(pass_layer: ScreenShaderGlobals.PassLayer) -> ColorRect:
	match pass_layer:
		ScreenShaderGlobals.PassLayer.FIRST:
			return pass1
	push_error("Unreachable code!")
	return null

func _ready() -> void:
	#if not Engine.is_editor_hint():
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("stdev", stdev)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("screen_size", screen_size)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("min_distance", min_distance)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("dynamic_downsample_target", dynamic_downsample_target)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("inverted_blur_strength", inverted_blur_strength)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("relative_blur_angle", relative_blur_angle)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("bidirectional", bidirectional)
	loaded = true
