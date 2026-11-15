class_name Atmosphere
extends Node2D
## Fireflies, drifting spirit motes and soft light shafts that follow the camera.

const BEAM_SPACING := 460.0

var _time := 0.0
var _scroll := 0.0


func _ready() -> void:
	z_index = 30
	material = Glow.additive()

	_add_particles(80, 9.0, Color(0.9, 1.0, 0.7, 0.9), 0.012, 0.03, 8.0, 34.0)
	_add_particles(26, 12.0, Color(0.45, 0.9, 1.0, 0.35), 0.10, 0.22, 6.0, 20.0)


func _add_particles(
	amount: int, life: float, color: Color,
	scale_min: float, scale_max: float, speed_min: float, speed_max: float
) -> void:
	var p := CPUParticles2D.new()
	p.amount = amount
	p.lifetime = life
	p.preprocess = life
	p.local_coords = false
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(1100, 640)
	p.direction = Vector2(0.3, -1.0)
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = speed_min
	p.initial_velocity_max = speed_max
	p.scale_amount_min = scale_min
	p.scale_amount_max = scale_max
	p.texture = Glow.texture()
	p.color = color
	p.material = Glow.additive()

	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	ramp.colors = PackedColorArray([
		Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0),
	])
	p.color_ramp = ramp
	add_child(p)


func _process(delta: float) -> void:
	_time += delta

	var cam := get_viewport().get_camera_2d()

	if cam != null:
		global_position = cam.get_screen_center_position()
		_scroll = global_position.x * 0.25

	queue_redraw()


func _draw() -> void:
	var first := int(floor(_scroll / BEAM_SPACING))
	var shift := fposmod(_scroll, BEAM_SPACING)

	for i in 7:
		var k := first + i
		var x := float(i - 3) * BEAM_SPACING - shift
		var width := 90.0 + 70.0 * absf(sin(float(k) * 12.9898))
		var strength := 0.035 + 0.04 * (0.5 + 0.5 * sin(_time * 0.35 + float(k) * 2.1))
		var strong := Color(0.75, 1.0, 0.9, strength)
		var clear := Color(0.75, 1.0, 0.9, 0.0)

		draw_polygon(
			PackedVector2Array([
				Vector2(x, -700), Vector2(x + width, -700),
				Vector2(x + width + 460.0, 700), Vector2(x + 460.0, 700),
			]),
			PackedColorArray([strong, strong, clear, clear])
		)
