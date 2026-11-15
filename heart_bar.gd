extends Control

const HEART_FULL := preload("res://HUD/heart_full.png")
const HEART_EMPTY := preload("res://HUD/heart_empty.png")

const HEART_SIZE := Vector2(34, 29)
const SPACING := 40.0

var max_health := 5
var health := 5


func setup(new_max: int) -> void:
	max_health = new_max
	health = new_max
	custom_minimum_size = Vector2(SPACING * max_health, HEART_SIZE.y)
	queue_redraw()


func set_health(value: int) -> void:
	health = value
	queue_redraw()


func _draw() -> void:
	for i in max_health:
		var texture := HEART_FULL if i < health else HEART_EMPTY
		draw_texture_rect(
			texture,
			Rect2(Vector2(i * SPACING, 0.0), HEART_SIZE),
			false
		)
