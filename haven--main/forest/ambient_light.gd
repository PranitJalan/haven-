class_name AmbientLight
extends Node2D
## A soft pool of coloured light that breathes slowly.

@export var color := Color(0.45, 0.9, 1.0)
@export var energy := 0.7
@export var size := 700.0
@export var breathe := 0.12

var _light: PointLight2D
var _time := 0.0
var _phase := 0.0


func _ready() -> void:
	_phase = fposmod(position.x * 0.013, TAU)
	_light = Glow.make_light(color, energy, size)
	add_child(_light)


func _process(delta: float) -> void:
	_time += delta
	_light.energy = energy * (1.0 + breathe * sin(_time * 0.9 + _phase))
