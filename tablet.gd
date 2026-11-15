class_name Tablet
extends Area2D

signal inscription_read(text: String)

@export var id := "t1"
@export_multiline var text := ""

var _read := false
var _glow := 0.0


func _ready() -> void:
	_glow = randf() * TAU
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_glow += delta
	queue_redraw()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_glow * 1.6)
	var stone := Color(0.1, 0.13, 0.18)
	var rune := Color(0.45, 0.88, 1.0, 0.35 + pulse * (0.1 if _read else 0.5))

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-26, 44), Vector2(-26, -34),
			Vector2(0, -52), Vector2(26, -34), Vector2(26, 44),
		]),
		stone
	)

	for i in 3:
		var y := -24.0 + i * 18.0
		draw_line(Vector2(-13, y), Vector2(13, y), rune, 3.0)


func _on_body_entered(body: Node2D) -> void:
	if _read or not body.is_in_group("player"):
		return

	_read = true
	inscription_read.emit(text)
