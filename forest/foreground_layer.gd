class_name ForegroundLayer
extends Node2D
## Dark foreground trees that slide past faster than the world, giving depth.
## Children are laid out in ordinary world coordinates.

@export var factor := 1.4


func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()

	if cam == null:
		return

	var center := cam.get_screen_center_position()
	scale = Vector2(factor, factor)
	position = center * (1.0 - factor)
