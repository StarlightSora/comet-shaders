@tool
extends Control

enum LuminosityCoefficientStandard {
	REC_2020,
	REC_709,
}

## The layer property of the underlying CanvasLayers. This controls the draw order.
@export var layer: int = 1:
	set(u):
		layer = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).get_parent().layer = u
## Hue shift amount, in radians. In the editor this is exposed as degrees.
@export_range(0.0, 360.0, 1.0, "radians_as_degrees") var hue: float = 0.0:
	set(u):
		hue = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("hue", u)
## Saturation. 1.0 is the normal saturation.
@export_range(-2.5, 2.5, 0.01) var saturation: float = 1.0:
	set(u):
		saturation = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("saturation", u)
## Contrast. 1.0 is the normal contrast.
@export_range(-2.5, 2.5, 0.01) var contrast: float = 1.0:
	set(u):
		contrast = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("contrast", u)
## Brightness. 0.0 is the normal brightness.
@export_range(-1.0, 1.0, 0.01) var brightness: float = 0.0:
	set(u):
		brightness = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("brightness", u)
## Gamma. 1.0 is the normal gamma.
@export_range(0.0, 5.0, 0.02) var gamma: float = 1.0:
	set(u):
		gamma = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("gamma", u)
## The luminosity coefficient standard to use for saturation calculation.
@export var luminosity_coefficient_standard: LuminosityCoefficientStandard = LuminosityCoefficientStandard.REC_2020:
	set(u):
		luminosity_coefficient_standard = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("use_rec_2020", u as int)
## Bias of the color correction to (or from) the edges of the screen. 0 to disable.
@export_range(-1.0, 1.0, 0.01) var radial_bias: float = 0.0:
	set(u):
		radial_bias = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_bias", u)
## Minimum distance from the center (or edge, if radial_bias < 0.0) for color correction starts taking effect.
## No-op if radial_bias == 0.0.
@export_range(-1.0, 1.0, 0.01) var radial_min_distance: float = 0.0:
	set(u):
		radial_min_distance = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_min_distance", u)

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
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("hue", hue)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("gamma", gamma)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("brightness", brightness)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("contrast", contrast)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("saturation", saturation)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("luminosity_coefficient_standard", luminosity_coefficient_standard as int)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_bias", radial_bias)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_min_distance", radial_min_distance)
	loaded = true
