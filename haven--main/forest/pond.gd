@tool
class_name Pond
extends Node2D
## Shallow glowing water. Origin is the top-left of the surface.

@export var size := Vector2(600, 90)
@export var tint := Color(0.2, 0.75, 0.9)

var _time := 0.0


func _ready() -> void:
	z_index = 2


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var top := Color(tint.r, tint.g, tint.b, 0.20)
	var deep := Color(tint.r * 0.6, tint.g * 0.8, tint.b, 0.55)

	draw_polygon(
		PackedVector2Array([
			Vector2.ZERO, Vector2(size.x, 0), size,
			Vector2(0, size.y),
		]),
		PackedColorArray([top, top, deep, deep])
	)

	var line := PackedVector2Array()
	var steps := int(size.x / 12.0)

	for i in steps + 1:
		var x := size.x * float(i) / float(steps)
		line.append(Vector2(x, sin(x * 0.03 + _time * 1.4) * 2.5))

	draw_polyline(line, Color(0.8, 1.0, 1.0, 0.75), 2.2)
	draw_polyline(line, Color(tint.r, tint.g, tint.b, 0.25), 8.0)

	for i in 9:
		var x := fposmod(float(i) * 83.0 + _time * 14.0, size.x)
		var y := size.y * (0.25 + 0.5 * fposmod(float(i) * 0.37, 1.0))
		draw_line(Vector2(x, y), Vector2(x + 26.0, y), Color(0.8, 1.0, 1.0, 0.18), 2.0)
