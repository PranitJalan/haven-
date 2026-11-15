class_name Rune
extends Area2D
## An ancient rune on a stone pedestal. Touch it to light it.

signal activated(rune: Rune)

@export var color := Color(0.45, 0.95, 1.0)

var lit := false

var _glow := 0.0
var _time := 0.0
var _light: PointLight2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 70.0
	shape.shape = circle
	shape.position = Vector2(0, -70)
	add_child(shape)

	_light = Glow.make_light(color, 0.0, 560.0)
	_light.position = Vector2(0, -110)
	add_child(_light)

	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	_glow = move_toward(_glow, 1.0 if lit else 0.0, delta * 0.9)
	_light.energy = _glow * (1.0 + 0.15 * sin(_time * 2.2))
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if lit or not body.is_in_group("player"):
		return

	lit = true
	Glow.burst(get_parent(), global_position + Vector2(0, -110), color, 24, 320.0)
	activated.emit(self)


func _draw() -> void:
	var stone := Color(0.1, 0.14, 0.19)
	var edge := Color(0.35, 0.5, 0.6, 0.8)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-58, 0), Vector2(-44, -42), Vector2(44, -42), Vector2(58, 0),
	]), stone)
	draw_polyline(PackedVector2Array([
		Vector2(-58, 0), Vector2(-44, -42), Vector2(44, -42), Vector2(58, 0),
	]), edge, 2.0)

	var c := Vector2(0, -112)
	var dim := Color(0.28, 0.4, 0.5, 0.9)
	var bright := Color(color.r, color.g, color.b, 1.0)
	var glyph := dim.lerp(bright, _glow)

	if _glow > 0.01:
		draw_circle(c, 90.0, Color(color.r, color.g, color.b, 0.07 * _glow))
		draw_circle(c, 60.0, Color(color.r, color.g, color.b, 0.14 * _glow))

	draw_arc(c, 36.0, 0.0, TAU, 40, glyph, 4.0)
	draw_arc(c, 22.0, 0.0, TAU, 32, glyph, 2.5)
	draw_line(c + Vector2(0, -36), c + Vector2(0, 36), glyph, 3.0)
	draw_line(c + Vector2(-26, 8), c + Vector2(26, 8), glyph, 3.0)
	draw_circle(c, 6.0, glyph.lerp(Color.WHITE, _glow * 0.7))
