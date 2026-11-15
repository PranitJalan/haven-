
extends Area2D

@export var speed := 450.0
@export var damage := 1
@export var lifetime := 6.0

var direction := Vector2.ZERO
var reflected := false
var shooter: Node2D


func _ready() -> void:
	add_to_group("enemy_projectiles")

	# Projectile collision layer = 2.
	# Detect player (layer 1) and enemies (layer 3).
	collision_layer = 2
	collision_mask = 5

	body_entered.connect(_on_body_entered)

	get_tree().create_timer(lifetime).timeout.connect(
		queue_free
	)


func setup(
	start_position: Vector2,
	target_position: Vector2,
	shooter_node: Node2D
) -> void:
	global_position = start_position
	shooter = shooter_node

	direction = (
		target_position - start_position
	).normalized()


func _physics_process(delta: float) -> void:
	# Keep aiming at the original shooter after reflection.
	if reflected:
		if is_instance_valid(shooter):
			direction = (
				shooter.global_position - global_position
			).normalized()

	global_position += direction * speed * delta


func reflect() -> void:
	if reflected:
		return

	reflected = true

	remove_from_group("enemy_projectiles")
	add_to_group("player_projectiles")

	if is_instance_valid(shooter):
		direction = (
			shooter.global_position - global_position
		).normalized()
	else:
		direction = -direction


func _on_body_entered(body: Node2D) -> void:

	if reflected:
		if body == shooter:
			if body.has_method("take_damage"):
				body.take_damage(damage)

			queue_free()

	else:
		if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)

			queue_free()
