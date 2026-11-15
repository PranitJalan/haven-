@tool
class_name TerrainPiece
extends StaticBody2D
## Solid forest ground. Give it one CollisionPolygon2D child (points ordered
## left to right along the top, then back along the bottom) and it draws a
## dark, rim-lit surface with grass, glowing tips and hanging vines.

@export var body_top := Color(0.12, 0.20, 0.25)
@export var body_bottom := Color(0.015, 0.03, 0.06)
@export var rim := Color(0.5, 1.0, 0.85)
@export var grass := Color(0.3, 0.8, 0.72)
@export_range(0.0, 2.0) var grass_amount := 1.0
@export var vines := false
@export var seed_value := 1

var _points := PackedVector2Array()
var _colors := PackedColorArray()
var _top_edges: Array = []
var _side_edges: Array = []
var _blades: Array = []
var _vines: Array = []


func _ready() -> void:
	var poly: CollisionPolygon2D = null

	for child in get_children():
		if child is CollisionPolygon2D:
			poly = child
			break

	if poly == null:
		return

	_points = poly.polygon

	for i in _points.size():
		_points[i] += poly.position

	_build()
	queue_redraw()


func _build() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	var n := _points.size()
	var min_y := INF

	for p in _points:
		min_y = minf(min_y, p.y)

	_colors.resize(n)

	for i in n:
		var t := clampf((_points[i].y - min_y) / 460.0, 0.0, 1.0)
		_colors[i] = body_top.lerp(body_bottom, t)

	var area := 0.0

	for i in n:
		var a := _points[i]
		var b := _points[(i + 1) % n]
		area += a.x * b.y - b.x * a.y

	var orient := 1.0 if area > 0.0 else -1.0

	for i in n:
		var a := _points[i]
		var b := _points[(i + 1) % n]
		var d := b - a
		var length := d.length()

		if length < 2.0:
			continue

		var normal := Vector2(d.y, -d.x) / length * orient

		if normal.y < -0.45:
			_top_edges.append([a, b])
			_scatter_blades(a, d, length, normal, rng)
		elif normal.y > 0.55:
			if vines and a.y < 600.0:
				_scatter_vines(a, d, length, rng)
		elif a.y < 600.0 or b.y < 600.0:
			_side_edges.append([a, b])


func _scatter_blades(
	a: Vector2,
	d: Vector2,
	length: float,
	normal: Vector2,
	rng: RandomNumberGenerator
) -> void:
	if grass_amount <= 0.01:
		return

	var step := 11.0 / grass_amount
	var travelled := rng.randf_range(0.0, step)

	while travelled < length:
		var base := a + d * (travelled / length)
		var blade_length := rng.randf_range(12.0, 36.0)
		var lean := rng.randf_range(-14.0, 14.0)
		var shade := rng.randf_range(0.65, 1.15)

		_blades.append({
			"base": base,
			"ctrl": base + normal * blade_length * 0.55 + Vector2(lean * 0.15, 0.0),
			"tip": base + normal * blade_length + Vector2(lean, 0.0),
			"color": Color(grass.r * shade, grass.g * shade, grass.b * shade, 0.92),
			"glow": rng.randf() < 0.12,
		})

		travelled += rng.randf_range(step * 0.6, step * 1.5)


func _scatter_vines(
	a: Vector2,
	d: Vector2,
	length: float,
	rng: RandomNumberGenerator
) -> void:
	var travelled := rng.randf_range(10.0, 50.0)

	while travelled < length:
		var base := a + d * (travelled / length)
		var vine_length := rng.randf_range(30.0, 150.0)
		var sway := rng.randf_range(-18.0, 18.0)
		var pts := PackedVector2Array()

		for s in 7:
			var t := float(s) / 6.0
			pts.append(base + Vector2(sway * t * t, vine_length * t))

		_vines.append(pts)
		travelled += rng.randf_range(40.0, 120.0)


func _draw() -> void:
	if _points.size() < 3:
		return

	draw_polygon(_points, _colors)

	var soft := Color(rim.r, rim.g, rim.b, 0.10)
	var mid := Color(rim.r, rim.g, rim.b, 0.24)
	var moss := Color(grass.r * 0.5, grass.g * 0.6, grass.b * 0.55, 0.55)

	for e in _side_edges:
		draw_line(e[0], e[1], Color(rim.r, rim.g, rim.b, 0.14), 5.0)
		draw_line(e[0], e[1], Color(rim.r, rim.g, rim.b, 0.40), 1.6)

	for e in _top_edges:
		draw_line(e[0] + Vector2(0, 5), e[1] + Vector2(0, 5), moss, 10.0)
		draw_line(e[0], e[1], soft, 15.0)
		draw_line(e[0], e[1], mid, 7.0)
		draw_line(e[0], e[1], rim, 2.2)

	for vine in _vines:
		draw_polyline(vine, Color(grass.r * 0.45, grass.g * 0.6, grass.b * 0.55, 0.85), 2.0)
		draw_circle(vine[vine.size() - 1], 2.6, Color(rim.r, rim.g, rim.b, 0.8))

	for b in _blades:
		draw_polyline(PackedVector2Array([b["base"], b["ctrl"], b["tip"]]), b["color"], 1.8)

		if b["glow"]:
			draw_circle(b["tip"], 5.0, Color(rim.r, rim.g, rim.b, 0.18))
			draw_circle(b["tip"], 2.2, Color(rim.r, rim.g, rim.b, 0.9))
