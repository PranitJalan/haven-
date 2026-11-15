@tool
class_name Waterfall
extends Node2D
## A glowing waterfall. Origin is where the water lands; it falls from above.

@export var width := 140.0
@export var height := 900.0
@export var tint := Color(0.55, 0.92, 1.0)
@export var streaks := 34
@export var mist := true

var _time := 0.0
var _streaks: Array = []


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(absf(position.x)) + 11

	for i in streaks:
		_streaks.append({
			"x": rng.randf_range(-0.46, 0.46) * width,
			"speed": rng.randf_range(260.0, 540.0),
			"len": rng.randf_range(40.0, 140.0),
			"off": rng.randf() * height,
			"w": rng.randf_range(1.5, 4.0),
			"a": rng.randf_range(0.2, 0.6),
		})

	material = Glow.additive()

	if Engine.is_editor_hint():
		return

	var light := Glow.make_light(tint, 0.55, 560.0)
	light.position = Vector2(0, -80)
	add_child(light)

	if not mist:
		return

	var p := CPUParticles2D.new()
	p.amount = 22
	p.lifetime = 3.2
	p.preprocess = 3.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(width * 0.6, 8.0)
	p.direction = Vector2(0, -1)
	p.spread = 35.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 14.0
	p.initial_velocity_max = 48.0
	p.scale_amount_min = 0.5
	p.scale_amount_max = 1.1
	p.texture = Glow.texture()
	p.color = Color(tint.r, tint.g, tint.b, 0.16)

	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	ramp.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	p.color_ramp = ramp
	add_child(p)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var w := width * 0.5
	var clear := Color(tint.r, tint.g, tint.b, 0.0)
	var body := Color(tint.r, tint.g, tint.b, 0.20)

	draw_polygon(
		PackedVector2Array([Vector2(-w, -height), Vector2(w, -height), Vector2(w, 0), Vector2(-w, 0)]),
		PackedColorArray([clear, clear, body, body])
	)

	var edge := Color(tint.r, tint.g, tint.b, 0.35)
	draw_line(Vector2(-w, -height * 0.7), Vector2(-w, 0), edge, 2.0)
	draw_line(Vector2(w, -height * 0.7), Vector2(w, 0), edge, 2.0)

	for s in _streaks:
		var y := fposmod(s["off"] + _time * s["speed"], height + s["len"]) - height
		var y0 := minf(y + s["len"], 0.0)
		var y1 := maxf(y, -height)

		if y0 <= y1:
			continue

		var fade := clampf(1.0 - absf(y1) / height, 0.15, 1.0)
		draw_line(
			Vector2(s["x"], y1), Vector2(s["x"], y0),
			Color(tint.r, tint.g, tint.b, s["a"] * fade), s["w"]
		)

	for i in 6:
		var phase := _time * 1.6 + float(i) * 1.7
		var x := sin(phase) * w * 0.9
		var r := 14.0 + 7.0 * sin(phase * 1.3)
		draw_circle(Vector2(x, -6.0 - 6.0 * sin(phase)), r, Color(tint.r, tint.g, tint.b, 0.08))
