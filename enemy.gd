extends CharacterBody2D

@export var gravity := 960.0
@export var acceleration := 200.0
@export var friction := 1800.0
@export var max_speed := 600.0

@export var detection_range := 1000.0
@export var stopping_distance := 750.0
@export var shoot_range := 1200.0

@export var health := 5

@export var shoot_interval := 2.0
@export var projectile_scene: PackedScene

@onready var shoot_timer: Timer = $ShootTimer

var direction := 0.0


func _ready() -> void:
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(shoot_projectile)
	shoot_timer.start()


func _physics_process(delta: float) -> void:
	direction = _direction_toward_player()

	if is_zero_approx(direction):
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	else:
		velocity.x = move_toward(
			velocity.x,
			max_speed * direction,
			acceleration * delta
		)

	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()


# Walks toward the player until it is close enough to stand and shoot.
func _direction_toward_player() -> float:
	var player := _find_player()

	if player == null:
		return 0.0

	if global_position.distance_to(player.global_position) > detection_range:
		return 0.0

	var horizontal_distance := absf(player.global_position.x - global_position.x)

	if horizontal_distance <= stopping_distance:
		return 0.0

	return signf(player.global_position.x - global_position.x)


func shoot_projectile() -> void:
	var player := _find_player()

	if player == null or projectile_scene == null:
		return

	if global_position.distance_to(player.global_position) > shoot_range:
		return

	var projectile := projectile_scene.instantiate() as EnemyProjectile

	if projectile == null:
		return

	get_tree().current_scene.add_child(projectile)
	projectile.setup(global_position, player.global_position, self)


func _find_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D


func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy health: ", health)

	if health <= 0:
		queue_free()
