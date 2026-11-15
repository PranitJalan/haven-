class_name GlowPlant
extends Area2D
## A bioluminescent plant. It pulses on its own and flares when you brush it.

@export var color := Color(0.4, 0.95, 1.0)
@export var stalk_height := 120.0
@export var bulbs := 3
@export var seed_value := 1
@export var light_size := 460.0
@export var energy := 0.75

var _flare := 0.0
var _time := 0.0
var _light: PointLight2D
var _stalks: Array = []
var _phase := 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 80.0
	shape.shape = circle
	shape.position = Vector2(0, -stalk_height * 0.5)
	add_child(shape)

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	_phase = rng.randf() * TAU

	for i in bulbs:
		var h := stalk_height * rng.randf_range(0.5, 1.0)
		var dx := rng.randf_range(-46.0, 46.0)
		_stalks.append({
			"base": Vector2(rng.randf_range(-12.0, 12.0), 0.0),
			"h": h,
			"dx": dx,
			"phase": rng.randf() * TAU,
			"radius": rng.randf_range(8.0, 14.0),
		})

	_light = Glow.make_light(color, energy, light_size)
	_light.position = Vector2(0, -stalk_height * 0.75)
	add_child(_light)

	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	_flare = move_toward(_flare, 0.0, delta * 0.7)
	_light.energy = energy * (0.8 + 0.2 * sin(_time * 1.7 + _phase)) + _flare * 1.3
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	_flare = 1.0
	Glow.burst(get_parent(), global_position + Vector2(0, -stalk_height * 0.8), color, 14, 160.0)


func _tip(s: Dictionary) -> Vector2:
	var sway := sin(_time * 1.3 + s["phase"]) * 5.0
	return s["base"] + Vector2(s["dx"] + sway, -s["h"])


func _draw() -> void:
	var stalk_color := Color(color.r * 0.25, color.g * 0.45, color.b * 0.45, 0.95)

	for s in _stalks:
		var tip: Vector2 = _tip(s)
		var base: Vector2 = s["base"]
		var ctrl := base + Vector2(s["dx"] * 0.1, -s["h"] * 0.6)
		var pts := PackedVector2Array()

		for i in 11:
			var t := float(i) / 10.0
			pts.append(base.lerp(ctrl, t).lerp(ctrl.lerp(tip, t), t))

		draw_polyline(pts, stalk_color, 3.0)

		var mid: Vector2 = pts[5]
		draw_line(mid, mid + Vector2(-22, -14), stalk_color, 2.0)
		draw_line(mid + Vector2(0, -8), mid + Vector2(20, -22), stalk_color, 2.0)

	var boost := 1.0 + _flare * 0.9

	for s in _stalks:
		var tip: Vector2 = _tip(s)
		var r: float = s["radius"] * (1.0 + _flare * 0.35)
		var pulse := 0.8 + 0.2 * sin(_time * 2.0 + s["phase"])

		draw_circle(tip, r * 3.4, Color(color.r, color.g, color.b, 0.07 * pulse * boost))
		draw_circle(tip, r * 2.1, Color(color.r, color.g, color.b, 0.16 * pulse * boost))
		draw_circle(tip, r * 1.2, Color(color.r, color.g, color.b, 0.55))
		draw_circle(tip, r * 0.6, Color(1, 1, 1, 0.95))
