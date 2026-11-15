extends Node2D

const WIDTH := 58.0
const HEIGHT := 7.0

@onready var enemy: Enemy = get_parent()


func _ready() -> void:
	position.y = -66.0 * enemy.body_scale - 26.0


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if enemy.is_dead or enemy.max_health <= 0:
		return

	var ratio := clampf(float(enemy.health) / float(enemy.max_health), 0.0, 1.0)

	if is_equal_approx(ratio, 1.0):
		return

	var width := WIDTH * (1.7 if enemy.is_boss else 1.0)
	var origin := Vector2(-width * 0.5, 0.0)

	draw_rect(Rect2(origin - Vector2(2, 2), Vector2(width + 4, HEIGHT + 4)), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(origin, Vector2(width, HEIGHT)), Color(0.2, 0.08, 0.1))
	draw_rect(Rect2(origin, Vector2(width * ratio, HEIGHT)), Color(1.0, 0.36, 0.42))
