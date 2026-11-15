extends Area2D

@export var speed := 450.0
@export var damage := 1

var direction := Vector2.ZERO
var reflected := false

func _ready() -> void:
	add_to_group("enemy_projectiles")
	body_entered.connect(_on_body_entered)

func setup(start_position: Vector2, target_position: Vector2) -> void:
	global_position = start_position
	direction = (target_position - start_position).normalized()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func reflect(new_direction: Vector2) -> void:
	reflected = true
	remove_from_group("enemy_projectiles")
	add_to_group("player_projectiles")

	direction = new_direction.normalized()

func _on_body_entered(body: Node2D) -> void:
	if reflected:
		if body.is_in_group("enemies"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
			queue_free()
	else:
		if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
			queue_free()
