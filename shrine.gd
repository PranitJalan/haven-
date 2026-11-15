class_name Shrine
extends Area2D

signal used

var _spent := false
var _pulse := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_pulse += delta
	queue_redraw()


func _draw() -> void:
	var alive := not _spent
	var glow := 0.5 + 0.5 * sin(_pulse * 2.0)
	var color := Color(0.5, 1.0, 0.75, (0.25 + glow * 0.45) if alive else 0.12)

	draw_arc(Vector2.ZERO, 40.0, PI, TAU, 24, color, 5.0)
	draw_line(Vector2(-40, 0), Vector2(40, 0), color, 4.0)

	if alive:
		draw_circle(Vector2(0, -16), 7.0 + glow * 3.0, Color(0.7, 1.0, 0.85, 0.6))


func _on_body_entered(body: Node2D) -> void:
	if _spent or not body.is_in_group("player"):
		return

	_spent = true
	used.emit()
