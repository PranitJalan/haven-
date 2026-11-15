class_name Portal
extends Area2D

signal entered

var is_open := false

var _time := 0.0


func _ready() -> void:
	monitoring = false
	visible = false
	body_entered.connect(_on_body_entered)


func open() -> void:
	if is_open:
		return

	is_open = true
	visible = true
	monitoring = true


func _process(delta: float) -> void:
	if not is_open:
		return

	_time += delta
	queue_redraw()


func _draw() -> void:
	for i in 4:
		var t := _time * (1.1 + i * 0.45)
		var radius := 34.0 + i * 17.0 + sin(t) * 5.0
		draw_arc(
			Vector2.ZERO,
			radius,
			t,
			t + PI * 1.25,
			32,
			Color(0.45, 0.9, 1.0, 0.75 - i * 0.14),
			5.0
		)

	draw_circle(
		Vector2.ZERO,
		26.0 + sin(_time * 3.0) * 3.0,
		Color(0.82, 0.97, 1.0, 0.5)
	)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		entered.emit()
