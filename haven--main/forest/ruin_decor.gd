@tool
class_name RuinDecor
extends Node2D
## Ancient stone: a broken pillar, or two pillars joined by an arch.
## Origin is the base (floor level) and the centre of the structure.

enum Kind { PILLAR, ARCH }

@export var kind: Kind = Kind.PILLAR
@export var height := 700.0
@export var width := 120.0
@export var span := 300.0
@export var glyph := Color(0.45, 0.95, 1.0)
@export var seed_value := 1


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	if kind == Kind.PILLAR:
		_pillar(Vector2.ZERO, width, height, true)
	else:
		_pillar(Vector2(-span * 0.5, 0), width, height, false)
		_pillar(Vector2(span * 0.5, 0), width, height, false)
		var center := Vector2(0, -height)
		var pts := PackedVector2Array()

		for i in 25:
			var a := PI + PI * float(i) / 24.0
			pts.append(center + Vector2(cos(a) * (span * 0.5 + width * 0.5), sin(a) * 150.0))

		for i in 25:
			var a := TAU - PI * float(i) / 24.0
			pts.append(center + Vector2(cos(a) * (span * 0.5 - width * 0.5), sin(a) * 90.0))

		draw_colored_polygon(pts, Color(0.09, 0.13, 0.18))
		draw_polyline(pts.slice(0, 25), Color(0.5, 0.7, 0.8, 0.5), 2.0)


func _pillar(at: Vector2, w: float, h: float, broken: bool) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + int(at.x)
	var half := w * 0.5
	var top_y := -h

	var pts := PackedVector2Array([
		at + Vector2(-half * 1.15, 0),
		at + Vector2(-half, top_y),
		at + Vector2(half, top_y),
		at + Vector2(half * 1.15, 0),
	])

	if broken:
		pts = PackedVector2Array([
			at + Vector2(-half * 1.15, 0),
			at + Vector2(-half, top_y + 40),
			at + Vector2(-half * 0.4, top_y - 24),
			at + Vector2(0, top_y + 30),
			at + Vector2(half * 0.5, top_y - 50),
			at + Vector2(half, top_y + 10),
			at + Vector2(half * 1.15, 0),
		])

	var top_color := Color(0.14, 0.20, 0.26)
	var bottom_color := Color(0.04, 0.07, 0.10)
	var colors := PackedColorArray()

	for p in pts:
		colors.append(bottom_color if p.y > -h * 0.3 else top_color)

	draw_polygon(pts, colors)
	draw_line(pts[0], pts[1], Color(0.5, 0.75, 0.85, 0.45), 2.0)

	for i in 3:
		var y := -h * (0.25 + 0.22 * float(i))
		draw_line(at + Vector2(-half, y), at + Vector2(half, y), Color(0.02, 0.04, 0.06, 0.8), 4.0)
		var c := at + Vector2(0, y - 26.0)
		draw_arc(c, 14.0, 0.0, TAU, 20, Color(glyph.r, glyph.g, glyph.b, 0.55), 2.0)
		draw_circle(c, 3.0, Color(glyph.r, glyph.g, glyph.b, 0.9))
