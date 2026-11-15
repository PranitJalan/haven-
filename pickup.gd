class_name Pickup
extends Area2D

enum Kind { COIN, ENERGY }

const BASE_SCALE := 0.6

signal collected(kind: Kind)

@export var kind: Kind = Kind.COIN
@export var bob_height := 7.0
@export var bob_speed := 3.0

@onready var sprite: Sprite2D = $Sprite2D

var _time := 0.0
var _base_y := 0.0


func _ready() -> void:
	_base_y = position.y
	_time = randf() * TAU
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta * bob_speed
	position.y = _base_y + sin(_time) * bob_height

	# Coins spin on the spot by squashing horizontally.
	if kind == Kind.COIN:
		sprite.scale.x = BASE_SCALE * maxf(absf(cos(_time * 0.8)), 0.32)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if kind == Kind.ENERGY and body.has_method("refill_shield"):
		body.call("refill_shield")

	collected.emit(kind)
	queue_free()
