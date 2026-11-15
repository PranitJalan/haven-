class_name HiddenArea
extends Area2D
## A secret nook hidden behind dark foliage. Walk in and the leaves part.

signal discovered

@export var size := Vector2(420, 280)
@export var cover_color := Color(0.012, 0.035, 0.05)
@export var seed_value := 1

var _outline := PackedVector2Array()
var _leaves: Array = []
var _revealed := false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	z_index = 20

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	add_child(shape)

	_build_cover()
	body_entered.connect(_on_body_entered)


func _build_cover() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var half := size * 0.5
	var corners := [
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y),
	]

	for c in 4:
		var from: Vector2 = corners[c]
		var to: Vector2 = corners[(c + 1) % 4]
		var edge := to - from
		var count := int(edge.length() / 34.0)
		var out := Vector2(edge.y, -edge.x).normalized()

		for i in count:
			var t := float(i) / float(count)
			var push := (14.0 if i % 2 == 0 else -6.0) + rng.randf_range(-6.0, 8.0)
			_outline.append(from + edge * t + out * push)

	for i in int(size.x * size.y / 2600.0):
		_leaves.append({
			"pos": Vector2(rng.randf_range(-half.x, half.x), rng.randf_range(-half.y, half.y)),
			"len": rng.randf_range(14.0, 30.0),
			"angle": rng.randf_range(0.0, TAU),
		})


func _draw() -> void:
	if _outline.size() < 3:
		return

	draw_colored_polygon(_outline, cover_color)

	var leaf := Color(0.04, 0.1, 0.12)

	for l in _leaves:
		var dir: Vector2 = Vector2.from_angle(l["angle"]) * l["len"]
		draw_line(l["pos"] - dir, l["pos"] + dir, leaf, 5.0)


func _on_body_entered(body: Node2D) -> void:
	if _revealed or not body.is_in_group("player"):
		return

	_revealed = true
	Glow.burst(get_parent(), global_position, Color(0.6, 1.0, 0.9), 26, 340.0)
	discovered.emit()

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.1)
	tween.tween_callback(hide)
