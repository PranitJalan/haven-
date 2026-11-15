extends Area2D

func _ready() -> void:
	monitoring = false
	area_entered.connect(_on_area_entered)

func _physics_process(_delta: float) -> void:
	var shielding = Input.is_action_pressed("Shield")

	monitoring = shielding
	visible = shielding

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_projectiles"):
		var player = get_parent()
		var enemy = get_tree().get_first_node_in_group("enemies")

		if enemy:
			var reflected_direction = (
				enemy.global_position - area.global_position
			).normalized()

			area.reflect(reflected_direction)
