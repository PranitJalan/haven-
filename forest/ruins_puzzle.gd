class_name RuinsPuzzle
extends Node2D
## Light every rune and the great door opens. Runes and the Gate are children.

signal solved

var _runes: Array[Rune] = []
var _solved := false
var _time := 0.0

@onready var gate: RuinsGate = $Gate


func _ready() -> void:
	for child in get_children():
		if child is Rune:
			var rune := child as Rune
			_runes.append(rune)
			rune.activated.connect(_on_rune_activated)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _on_rune_activated(_rune: Rune) -> void:
	var lit := 0

	for rune in _runes:
		if rune.lit:
			lit += 1

	gate.set_progress(lit, _runes.size())

	if lit == _runes.size() and not _solved:
		_solved = true
		gate.open()
		solved.emit()


## Trails of light drift from each lit rune to the door.
func _draw() -> void:
	var target := gate.position + Vector2(0, -gate.door_size.y * 0.5)

	for rune in _runes:
		if not rune.lit:
			continue

		var from := rune.position + Vector2(0, -112)

		for i in 14:
			var t := fposmod(float(i) / 14.0 + _time * 0.12, 1.0)
			var p := from.lerp(target, t) + Vector2(0, sin(t * PI) * -40.0)
			var fade := sin(t * PI)
			draw_circle(p, 9.0, Color(rune.color.r, rune.color.g, rune.color.b, 0.10 * fade))
			draw_circle(p, 3.2, Color(rune.color.r, rune.color.g, rune.color.b, 0.85 * fade))
