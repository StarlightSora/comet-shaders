@tool
extends Control

var loaded: bool = false

## The layer property of the underlying CanvasLayers. This controls the draw order.
@export var layer: int = 1:
	set(u):
		layer = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).get_parent().layer = u
## Offset direction of the chromatic aberration for the red channel.
@export_range(0.0, 360.0, 1.0, "radians_as_degrees") var angle_r: float = 0.0:
	set(u):
		angle_r = u
		velocity_r = strength_r * Vector2.from_angle(angle_r)
## Offset amount of the chromatic aberration for the red channel.
@export_range(0.0, 0.05, 0.0005) var strength_r: float = 0.005:
	set(u):
		strength_r = u
		velocity_r = strength_r * Vector2.from_angle(angle_r)
## Offset vector of the chromatic aberration for the red channel.
var velocity_r: Vector2 = Vector2.ZERO:
	set(u):
		velocity_r = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("velocity_r", velocity_r)
## Offset direction of the chromatic aberration for the green channel.
@export_range(0.0, 360.0, 1.0, "radians_as_degrees") var angle_g: float = TAU/3.0:
	set(u):
		angle_g = u
		velocity_g = strength_g * Vector2.from_angle(angle_g)
## Offset amount of the chromatic aberration for the green channel.
@export_range(0.0, 0.05, 0.0005) var strength_g: float = 0.005:
	set(u):
		strength_g = u
		velocity_g = strength_g * Vector2.from_angle(angle_g)
## Offset vector of the chromatic aberration for the green channel.
var velocity_g: Vector2 = Vector2.ZERO:
	set(u):
		velocity_g = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("velocity_g", velocity_g)
## Offset direction of the chromatic aberration for the blue channel.
@export_range(0.0, 360.0, 1.0, "radians_as_degrees") var angle_b: float = 2.0*TAU/3.0:
	set(u):
		angle_b = u
		velocity_b = strength_b * Vector2.from_angle(angle_b)
## Offset amount of the chromatic aberration for the blue channel.
@export_range(0.0, 0.05, 0.0005) var strength_b: float = 0.005:
	set(u):
		strength_b = u
		velocity_b = strength_b * Vector2.from_angle(angle_b)
## Offset vector of the chromatic aberration for the blue channel.
var velocity_b: Vector2 = Vector2.ZERO:
	set(u):
		velocity_g = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("velocity_b", velocity_b)
## Bias of the chromatic aberration to (or from) the edges of the screen. 0 to disable.
@export_range(-1.0, 1.0, 0.01) var radial_bias: float = 0.0:
	set(u):
		radial_bias = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_bias", radial_bias)
## Minimum distance from the center (or edge, if radial_bias < 0.0) for chromatic aberration starts taking effect.
## No-op if radial_bias == 0.0.
@export_range(-1.0, 1.0, 0.01) var radial_min_distance: float = 0.0:
	set(u):
		radial_min_distance = u
		if loaded:
			node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_min_distance", radial_min_distance)

@onready var pass1 = $Pass1/ColorRect
func node_of(pass_layer: ScreenShaderGlobals.PassLayer) -> ColorRect:
	match pass_layer:
		ScreenShaderGlobals.PassLayer.FIRST:
			return pass1
	push_error("Unreachable code!")
	return null

func _ready() -> void:
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("velocity_r", velocity_r)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("velocity_g", velocity_g)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("velocity_b", velocity_b)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_bias", radial_bias)
	node_of(ScreenShaderGlobals.PassLayer.FIRST).material.set_shader_parameter("radial_min_distance", radial_min_distance)
	loaded = true
