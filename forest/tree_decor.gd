@tool
class_name TreeDecor
extends Node2D
## A towering forest tree silhouette. Origin is the base of the trunk.

@export var trunk_width := 170.0
@export var tree_height := 1500.0
@export var trunk_color := Color(0.03, 0.07, 0.10)
@export var trunk_top_color := Color(0.07, 0.15, 0.19)
@export var rim := Color(0.4, 0.9, 0.9, 0.45)
@export var leaf_color := Color(0.03, 0.09, 0.11, 0.96)
@export var leaf_glow := Color(0.5, 1.0, 0.8)
@export var canopy := true
@export var hanging := true
@export var bushes := 0
@export var lean := 0.0
@export var seed_value := 1

var _trunk := PackedVector2Array()
var _trunk_colors := PackedColorArray()
var _left_edge := PackedVector2Array()
var _branches: Array = []
var _blobs: Array = []
var _vines: Array = []
var _sparks: Array = []


func _ready() -> void:
	_build()
	queue_redraw()


func _trunk_x(t: float) -> float:
	return lean * tree_height * t * t * 0.3


func _build() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	var steps := 16
	var left: Array[Vector2] = []
	var right: Array[Vector2] = []

	for i in steps + 1:
		var t := float(i) / float(steps)
		var half := lerpf(trunk_width * 0.5, trunk_width * 0.27, t)

		if t < 0.08:
			half *= lerpf(1.4, 1.0, t / 0.08)

		var wobble := rng.randf_range(-5.0, 5.0)
		var cx := _trunk_x(t)
		left.append(Vector2(cx - half + wobble, -t * tree_height))
		right.append(Vector2(cx + half + wobble, -t * tree_height))

	_trunk.append(Vector2(left[0].x - trunk_width * 0.55, 26.0))

	for p in left:
		_trunk.append(p)

	for i in range(right.size() - 1, -1, -1):
		_trunk.append(right[i])

	_trunk.append(Vector2(right[0].x + trunk_width * 0.55, 26.0))

	for p in _trunk:
		var t := clampf(-p.y / tree_height, 0.0, 1.0)
		_trunk_colors.append(trunk_color.lerp(trunk_top_color, t))

	_left_edge = PackedVector2Array(left)

	var top := Vector2(_trunk_x(1.0), -tree_height)

	for i in 4:
		var t := rng.randf_range(0.45, 0.85)
		var side := -1.0 if i % 2 == 0 else 1.0
		var start := Vector2(_trunk_x(t), -t * tree_height)
		var end := start + Vector2(side * rng.randf_range(260.0, 520.0), -rng.randf_range(120.0, 320.0))
		_branches.append([start, end, trunk_width * rng.randf_range(0.12, 0.2)])

		if canopy:
			_cluster(end, rng.randf_range(110.0, 190.0), rng)

	if canopy:
		_cluster(top, 230.0, rng)
		_cluster(top + Vector2(-220, 60), 170.0, rng)
		_cluster(top + Vector2(240, 80), 180.0, rng)

	for i in bushes:
		var t := rng.randf_range(0.08, 0.55)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		var pos := Vector2(_trunk_x(t) + side * trunk_width * 0.45, -t * tree_height)
		_cluster(pos, rng.randf_range(70.0, 130.0), rng)

	if hanging:
		for i in 9:
			var base := top + Vector2(rng.randf_range(-320.0, 320.0), rng.randf_range(0.0, 120.0))
			var length := rng.randf_range(220.0, 620.0)
			var sway := rng.randf_range(-30.0, 30.0)
			var pts := PackedVector2Array()

			for s in 9:
				var u := float(s) / 8.0
				pts.append(base + Vector2(sway * u * u, length * u))

			_vines.append(pts)


func _cluster(center: Vector2, radius: float, rng: RandomNumberGenerator) -> void:
	for i in 7:
		var offset := Vector2(rng.randf_range(-0.8, 0.8), rng.randf_range(-0.55, 0.55)) * radius
		_blobs.append([center + offset, radius * rng.randf_range(0.5, 0.85)])

	for i in 6:
		_sparks.append(center + Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-0.7, 0.7)) * radius)


func _draw() -> void:
	if _trunk.size() < 3:
		return

	for b in _branches:
		draw_line(b[0], b[1], trunk_color.lerp(trunk_top_color, 0.5), b[2])

	draw_polygon(_trunk, _trunk_colors)
	draw_polyline(_left_edge, Color(rim.r, rim.g, rim.b, rim.a * 0.35), 9.0)
	draw_polyline(_left_edge, rim, 2.5)

	for blob in _blobs:
		draw_circle(blob[0], blob[1], leaf_color)

	for v in _vines:
		draw_polyline(v, Color(leaf_color.r * 1.4, leaf_color.g * 1.5, leaf_color.b * 1.4, 0.9), 3.0)
		draw_circle(v[v.size() - 1], 3.0, Color(leaf_glow.r, leaf_glow.g, leaf_glow.b, 0.7))

	for s in _sparks:
		draw_circle(s, 4.0, Color(leaf_glow.r, leaf_glow.g, leaf_glow.b, 0.14))
		draw_circle(s, 1.8, Color(leaf_glow.r, leaf_glow.g, leaf_glow.b, 0.65))
