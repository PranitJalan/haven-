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
	if kind == Kind.COIN:
		draw_circle(Vector2.ZERO, 13.0, Color(1.0, 0.8, 0.28))
		draw_circle(Vector2.ZERO, 8.0, Color(1.0, 0.94, 0.68))
	else:
		draw_rect(Rect2(-11, -14, 22, 28), Color(0.18, 0.72, 1.0))
		draw_rect(Rect2(-6, -9, 12, 18), Color(0.72, 0.95, 1.0))


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if kind == Kind.ENERGY and body.has_method("refill_shield"):
		body.call("refill_shield")

	collected.emit(kind)
	queue_free()
