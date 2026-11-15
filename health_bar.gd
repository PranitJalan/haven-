extends Control

const BAR_SIZE := Vector2(236, 20)
const BORDER := 2.0

const FILL_HIGH := Color(0.35, 0.9, 0.55)
const FILL_MID := Color(1.0, 0.78, 0.25)
const FILL_LOW := Color(0.95, 0.3, 0.35)
const BACK := Color(0.08, 0.1, 0.14, 0.9)
const EDGE := Color(0.45, 0.88, 1.0, 0.8)

var max_health := 5
var health := 5


func setup(new_max: int) -> void:
	max_health = maxi(new_max, 1)
	health = max_health
	custom_minimum_size = BAR_SIZE
	queue_redraw()


func set_health(value: int) -> void:
	health = clampi(value, 0, max_health)
	queue_redraw()


func _draw() -> void:
	var ratio := float(health) / float(max_health)
	var fill := FILL_LOW

	if ratio > 0.6:
		fill = FILL_HIGH
	elif ratio > 0.3:
		fill = FILL_MID

	draw_rect(Rect2(Vector2.ZERO, BAR_SIZE), BACK)
	draw_rect(
		Rect2(
			Vector2(BORDER, BORDER),
			Vector2((BAR_SIZE.x - BORDER * 2.0) * ratio, BAR_SIZE.y - BORDER * 2.0)
		),
		fill
	)
	draw_rect(Rect2(Vector2.ZERO, BAR_SIZE), EDGE, false, 2.0)

	# notches so you can still read individual hits
	for i in range(1, max_health):
		var x := BORDER + (BAR_SIZE.x - BORDER * 2.0) * (float(i) / float(max_health))
		draw_line(Vector2(x, BORDER), Vector2(x, BAR_SIZE.y - BORDER), BACK, 1.5)
