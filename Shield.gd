extends Area2D

const ARC_RADIUS := 95.0
const ARC_HALF_ANGLE := PI / 3.0

@onready var player: CharacterBody2D = get_parent()

var is_shielding := false


func _ready() -> void:
	monitoring = false
	visible = false
	area_entered.connect(_on_area_entered)


func _physics_process(_delta: float) -> void:
	# Flipping by rotation instead of a negative scale keeps the hitbox valid.
	rotation = 0.0 if player.facing_direction > 0.0 else PI

	var shielding := Input.is_action_pressed("shield")

	if shielding == is_shielding:
		return

	is_shielding = shielding
	monitoring = shielding
	visible = shielding
	queue_redraw()


func _draw() -> void:
	draw_arc(
		Vector2.ZERO,
		ARC_RADIUS,
		-ARC_HALF_ANGLE,
		ARC_HALF_ANGLE,
		24,
		Color(0.3, 0.8, 1.0, 0.95),
		10.0
	)


func _on_area_entered(area: Area2D) -> void:
	var projectile := area as EnemyProjectile

	if projectile != null:
		projectile.reflect()
