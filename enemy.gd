class_name Enemy
extends CharacterBody2D

signal died

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
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction := 0.0
var is_dead := false

# True while a one-shot animation (attack, damage, death) owns the sprite.
var _busy := false


func _ready() -> void:
	shoot_timer.wait_time = shoot_interval
	shoot_timer.timeout.connect(shoot_projectile)
	shoot_timer.start()

	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	direction = 0.0 if is_dead else _direction_toward_player()

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

	if not is_dead:
		_update_animation()


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


func _update_animation() -> void:
	var player := _find_player()

	if player != null:
		sprite.flip_h = player.global_position.x < global_position.x

	if _busy:
		return

	if is_zero_approx(direction):
		_play("idle")
	else:
		_play("walk")


func _play(animation_name: StringName) -> void:
	if sprite.animation != animation_name:
		sprite.play(animation_name)


# Restarts from frame 0 even if the same animation is already showing.
func _play_once(animation_name: StringName) -> void:
	_busy = true
	sprite.animation = animation_name
	sprite.frame = 0
	sprite.play(animation_name)


func _on_animation_finished() -> void:
	if sprite.animation == &"death":
		died.emit()
		queue_free()
	else:
		_busy = false


func shoot_projectile() -> void:
	if is_dead:
		return

	var player := _find_player()

	if player == null or projectile_scene == null:
		return

	if global_position.distance_to(player.global_position) > shoot_range:
		return

	var projectile := projectile_scene.instantiate() as EnemyProjectile

	if projectile == null:
		return

	_play_once("attack")

	get_tree().current_scene.add_child(projectile)
	projectile.setup(global_position, player.global_position, self)


func _find_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D


func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	print("Enemy health: ", health)

	if health <= 0:
		_die()
	else:
		_play_once("damage")


func _die() -> void:
	is_dead = true
	shoot_timer.stop()
	set_collision_layer_value(3, false)
	_play_once("death")
