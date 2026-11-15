class_name BounceShroom
extends Area2D
## A springy glowing mushroom. Step on it to be launched upward.

@export var boost := 1500.0
@export var color := Color(0.55, 0.78, 1.0)

var _squash := 0.0
var _cooldown := 0.0
var _time := 0.0
var _light: PointLight2D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(110, 40)
	shape.shape = rect
	shape.position = Vector2(0, -34)
	add_child(shape)

	_light = Glow.make_light(color, 0.8, 380.0)
	_light.position = Vector2(0, -50)
	add_child(_light)

	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	_cooldown = maxf(_cooldown - delta, 0.0)
	_squash = move_toward(_squash, 0.0, delta * 2.6)
	_light.energy = 0.7 + 0.15 * sin(_time * 2.0) + _squash * 1.5
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _cooldown > 0.0:
		return

	var player := body as CharacterBody2D

	if player == null or player.velocity.y < -80.0:
		return

	player.velocity.y = -boost
	_squash = 1.0
	_cooldown = 0.4
	Glow.burst(get_parent(), global_position + Vector2(0, -60), color, 20, 300.0)


func _draw() -> void:
	var squish := 1.0 - _squash * 0.35
	var stem := Color(0.12, 0.22, 0.3)
	var cap := Color(color.r * 0.55, color.g * 0.6, color.b * 0.9)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-12, 0), Vector2(-9, -26 * squish), Vector2(9, -26 * squish), Vector2(12, 0),
	]), stem)

	var dome := PackedVector2Array()

	for i in 17:
		var a := PI + PI * float(i) / 16.0
		dome.append(Vector2(cos(a) * 62.0, -26.0 * squish + sin(a) * 36.0 * squish))

	draw_colored_polygon(dome, cap)
	draw_polyline(dome, Color(color.r, color.g, color.b, 0.95), 2.4)

	for spot in [Vector2(-30, -42), Vector2(4, -54), Vector2(34, -40), Vector2(-8, -36)]:
		var p: Vector2 = spot * Vector2(1.0, squish)
		var pulse := 0.65 + 0.35 * sin(_time * 2.4 + p.x)
		draw_circle(p, 9.0, Color(color.r, color.g, color.b, 0.18 * pulse))
		draw_circle(p, 4.5, Color(0.85, 0.97, 1.0, 0.9 * pulse))
