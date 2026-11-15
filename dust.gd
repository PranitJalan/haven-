extends Node2D

const LIFETIME := 0.45
const PUFF_COUNT := 5

var _age := 0.0
var _offsets: Array[Vector2] = []


func _ready() -> void:
	for i in PUFF_COUNT:
		_offsets.append(Vector2(randf_range(-34.0, 34.0), randf_range(-6.0, 6.0)))


func _process(delta: float) -> void:
	_age += delta
	queue_redraw()

	if _age >= LIFETIME:
		queue_free()


func _draw() -> void:
	var t := _age / LIFETIME
	var alpha := (1.0 - t) * 0.5

	for offset in _offsets:
		draw_circle(offset * (0.5 + t * 1.4), 4.0 + t * 12.0, Color(0.85, 0.9, 0.95, alpha))
