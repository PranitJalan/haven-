class_name RuinsGate
extends StaticBody2D
## A great stone door sealed by three runes. Origin is at the base of the door.

@export var door_size := Vector2(130, 820)
@export var seal_color := Color(0.45, 0.95, 1.0)

var _progress := 0.0
var _open := false
var _time := 0.0
var _light: PointLight2D


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = door_size
	shape.shape = rect
	shape.position = Vector2(0, -door_size.y * 0.5)
	add_child(shape)

	_light = Glow.make_light(seal_color, 0.0, 700.0)
	_light.position = Vector2(0, -door_size.y * 0.5)
	add_child(_light)


func _process(delta: float) -> void:
	_time += delta
	_light.energy = _progress * (0.8 + 0.1 * sin(_time * 2.0))
	queue_redraw()


func set_progress(lit: int, total: int) -> void:
	var tween := create_tween()
	tween.tween_property(self, "_progress", float(lit) / float(maxi(total, 1)), 0.8)


func open() -> void:
	if _open:
		return

	_open = true

	var player := get_tree().get_first_node_in_group("player")

	if player != null and player.has_method("shake_camera"):
		player.call("shake_camera", 10.0)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y - door_size.y - 60.0, 3.2)


func _draw() -> void:
	var w := door_size.x * 0.5
	var h := door_size.y
	var top := Color(0.2, 0.26, 0.32)
	var bottom := Color(0.06, 0.09, 0.13)

	draw_polygon(
		PackedVector2Array([Vector2(-w, 0), Vector2(-w, -h), Vector2(w, -h), Vector2(w, 0)]),
		PackedColorArray([bottom, top, top, bottom])
	)
	draw_rect(Rect2(-w, -h, door_size.x, h), Color(0.5, 0.65, 0.75, 0.5), false, 2.0)

	for i in range(1, 6):
		var y := -h * float(i) / 6.0
		draw_line(Vector2(-w, y), Vector2(w, y), Color(0.02, 0.04, 0.06, 0.7), 3.0)

	var c := Vector2(0, -h * 0.5)
	var base := Color(0.3, 0.42, 0.52)
	var glow := base.lerp(seal_color, _progress)

	if _progress > 0.01:
		draw_circle(c, 70.0, Color(seal_color.r, seal_color.g, seal_color.b, 0.12 * _progress))

	draw_arc(c, 44.0, 0.0, TAU, 40, glow, 4.0)
	draw_arc(c, 28.0, 0.0, TAU, 32, glow, 3.0)

	for i in 3:
		var a := -PI * 0.5 + TAU * float(i) / 3.0
		var on := _progress > (float(i) + 0.5) / 3.0 - 0.001
		var col := seal_color if on else base
		draw_circle(c + Vector2.from_angle(a) * 36.0, 7.0, col)
