class_name Pickup
extends Area2D

enum Kind { COIN, ENERGY }

signal collected(kind: Kind)

@export var kind: Kind = Kind.COIN
@export var bob_height := 7.0
@export var bob_speed := 3.0

var _time := 0.0
var _base_y := 0.0


func _ready() -> void:
	_base_y = position.y
	_time = randf() * TAU
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta * bob_speed
	position.y = _base_y + sin(_time) * bob_height
	queue_redraw()


func _draw() -> void:
	var spin := absf(cos(_time * 0.9))

	if kind == Kind.COIN:
		draw_circle(Vector2.ZERO, 14.0, Color(0.85, 0.6, 0.12))
		draw_ellipse(Vector2.ZERO, 11.0 * spin + 2.0, 11.0, Color(1.0, 0.82, 0.3))
		draw_ellipse(Vector2.ZERO, 6.0 * spin + 1.0, 6.0, Color(1.0, 0.95, 0.72))
	else:
		draw_circle(Vector2.ZERO, 15.0, Color(0.15, 0.6, 0.95, 0.5))
		draw_circle(Vector2.ZERO, 10.0, Color(0.35, 0.85, 1.0))
		draw_circle(Vector2(-3.0, -3.0), 4.0, Color(0.9, 0.99, 1.0))



func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if kind == Kind.ENERGY and body.has_method("refill_shield"):
		body.call("refill_shield")

	collected.emit(kind)
	queue_free()
