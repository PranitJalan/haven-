
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
	add_to_group("enemies")

	# Enemy collision layer = 3.
	collision_layer = 4

	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(shoot_projectile)
	shoot_timer.start()


func _physics_process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")

	direction = 0.0

	if player != null:
		var distance_to_player = global_position.distance_to(
			player.global_position
		)

		var horizontal_distance = abs(
			player.global_position.x - global_position.x
		)

		if distance_to_player <= detection_range:
			if horizontal_distance > stopping_distance:
				direction = sign(
					player.global_position.x - global_position.x
				)

	if direction != 0:
		velocity.x = move_toward(
			velocity.x,
			max_speed * direction,
			acceleration * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			friction * delta
		)

	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()


func shoot_projectile() -> void:
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if projectile_scene == null:
		push_warning("Assign enemy_projectile.tscn in the Inspector!")
		return

	if global_position.distance_to(player.global_position) > shoot_range:
		return

	var projectile = projectile_scene.instantiate()

	get_tree().current_scene.add_child(projectile)

	projectile.setup(
		global_position,
		player.global_position,
		self
	)


func take_damage(amount: int) -> void:
	health -= amount

	print("Enemy health: ", health)

	if health <= 0:
		queue_free()
