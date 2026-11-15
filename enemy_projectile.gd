class_name EnemyProjectile
extends Area2D

@export var speed := 450.0
@export var damage := 1
@export var lifetime := 6.0

var direction := Vector2.ZERO
var reflected := false
var shooter: Node2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func setup(
	start_position: Vector2,
	target_position: Vector2,
	shooter_node: Node2D
) -> void:
	global_position = start_position
	shooter = shooter_node
	direction = (target_position - start_position).normalized()
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	# A reflected rocket keeps steering back toward whoever fired it.
	if reflected and is_instance_valid(shooter):
		direction = (shooter.global_position - global_position).normalized()

	rotation = direction.angle()
	global_position += direction * speed * delta


func reflect() -> void:
	if reflected:
		return

	reflected = true

	remove_from_group("enemy_projectiles")
	add_to_group("player_projectiles")

	if is_instance_valid(shooter):
		direction = (shooter.global_position - global_position).normalized()
	else:
		direction = -direction


func _on_body_entered(body: Node2D) -> void:
	if reflected:
		if body != shooter:
			return
	elif not body.is_in_group("player"):
		return

	if body.has_method("take_damage"):
		body.call("take_damage", damage)

	queue_free()
