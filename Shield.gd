
extends Area2D

var is_shielding := false

func _ready() -> void:
	monitoring = false

	# Detect enemy projectiles (collision layer 2).
	collision_layer = 0
	collision_mask = 2

	area_entered.connect(_on_area_entered)


func _physics_process(_delta: float) -> void:
	var player = get_parent()

	# Position the shield in the direction the player faces.
	var facing = player.facing_direction

	position = Vector2(125.0 * facing, 0)
	scale.x = facing

	# Raise shield while Shift is held.
	var shielding = Input.is_action_pressed("Shield")

	if shielding != is_shielding:
		is_shielding = shielding
		monitoring = shielding
		visible = shielding
		queue_redraw()


func _draw() -> void:
	if is_shielding:
		draw_arc(
			Vector2.ZERO,
			65.0,
			-PI / 2,
			PI / 2,
			32,
			Color(0.3, 0.8, 1.0, 0.95),
			9.0
		)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_projectiles"):
		if area.has_method("reflect"):
			area.reflect()
