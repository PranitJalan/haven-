extends Control

const HEART_SIZE := 30.0
const SPACING := 36.0
const FULL := Color(1.0, 0.33, 0.42)
const EMPTY := Color(0.22, 0.24, 0.3)

var max_health := 5
var health := 5


func setup(new_max: int) -> void:
	max_health = new_max
	health = new_max
	custom_minimum_size = Vector2(SPACING * max_health, HEART_SIZE + 6.0)
	queue_redraw()


func set_health(value: int) -> void:
	health = value
	queue_redraw()


func _draw() -> void:
	for i in max_health:
		var center := Vector2(HEART_SIZE * 0.55 + i * SPACING, HEART_SIZE * 0.55)
		_draw_heart(center, FULL if i < health else EMPTY)


func _draw_heart(center: Vector2, color: Color) -> void:
	var r := HEART_SIZE * 0.27

	draw_circle(center + Vector2(-r * 0.8, -r * 0.45), r, color)
	draw_circle(center + Vector2(r * 0.8, -r * 0.45), r, color)
	draw_colored_polygon(
		PackedVector2Array([
			center + Vector2(-r * 1.72, -r * 0.2),
			center + Vector2(r * 1.72, -r * 0.2),
			center + Vector2(0.0, r * 1.95),
		]),
		color
	)
