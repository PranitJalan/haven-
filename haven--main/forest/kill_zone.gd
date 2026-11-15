class_name KillZone
extends Area2D
## Falling into this costs a heart and returns you to the last lantern.


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var level := get_tree().current_scene

	if level.has_method("respawn_player"):
		level.call("respawn_player")
