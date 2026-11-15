class_name Checkpoint
extends Area2D
## A spirit lantern. Touching it sets where you return after a fall.

var _active := false
var _glow := 0.0
var _time := 0.0
var _light: PointLight2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(160, 240)
	shape.shape = rect
	shape.position = Vector2(0, -120)
	add_child(shape)

	_light = Glow.make_light(Color(1.0, 0.85, 0.5), 0.0, 520.0)
	_light.position = Vector2(0, -110)
	add_child(_light)

	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	_glow = move_toward(_glow, 1.0 if _active else 0.15, delta * 0.8)
	_light.energy = _glow * (0.8 + 0.1 * sin(_time * 3.0))
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if _active or not body.is_in_group("player"):
		return

	_active = true
	Glow.burst(get_parent(), global_position + Vector2(0, -110), Color(1.0, 0.85, 0.5), 22, 280.0)

	var level := get_tree().current_scene

	if level.has_method("set_checkpoint"):
		level.call("set_checkpoint", global_position + Vector2(0, -70))


func _draw() -> void:
	var stone := Color(0.1, 0.14, 0.18)
	var warm := Color(1.0, 0.85, 0.5)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-18, 0), Vector2(-12, -90), Vector2(12, -90), Vector2(18, 0),
	]), stone)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-30, -90), Vector2(-24, -104), Vector2(24, -104), Vector2(30, -90),
	]), stone)

	var flame := Vector2(0, -122 + sin(_time * 4.0) * 2.0)
	draw_circle(flame, 36.0 * _glow + 10.0, Color(warm.r, warm.g, warm.b, 0.10 * _glow + 0.03))
	draw_circle(flame, 17.0, Color(warm.r, warm.g, warm.b, 0.25 + 0.5 * _glow))
	draw_circle(flame, 8.0, Color(1, 0.97, 0.88, 0.5 + 0.5 * _glow))
