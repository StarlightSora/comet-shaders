@tool
extends Control
## Color tint. This tints the screen by multipying the incoming colors with the given tint color.
##
## Time complexity per pixel: O(1).

## The layer property of the underlying CanvasLayers. This controls the draw order.
@export var layer: int = 1:
	set(u):
		layer = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).get_parent().layer = u
## The tint color to apply. Implicitly gets converted to Vector4 form.
@export var tint: Color = Color(1.0, 1.0, 1.0, 1.0):
	set(u):
		tint = u
		tint_vec4 = Vector4(tint.r, tint.g, tint.b, tint.a)
## The tint color to apply, in Vector4 form.
var tint_vec4: Vector4 = Vector4(1.0, 1.0, 1.0 ,1.0):
	set(u):
		tint_vec4 = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("tint", tint_vec4)
## Bias of the color correction to (or from) the edges of the screen. 0 to disable.
@export_range(-1.0, 1.0, 0.01) var radial_bias: float = 0.0:
	set(u):
		radial_bias = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_bias", radial_bias)
## Minimum distance from the center (or edge, if radial_bias < 0.0) for color correction starts taking effect.
## No-op if radial_bias == 0.0.
@export_range(-1.0, 1.0, 0.01) var radial_min_distance: float = 0.0:
	set(u):
		radial_min_distance = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_min_distance", radial_min_distance)

var loaded: bool = false

@onready var pass1 = $Pass1/ColorRect
func node_of(pass_layer: ScreenShaderGlobals.PassLayer) -> ColorRect:
	match pass_layer:
		ScreenShaderGlobals.PassLayer.FIRST:
			return pass1
	push_error("Unreachable code!")
	return null

func _ready() -> void:
	node_of(ScreenShaderGlobals.PassLayer.FIRST).get_parent().layer = layer
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("tint", tint_vec4)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_bias", radial_bias)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_min_distance", radial_min_distance)
	loaded = true
