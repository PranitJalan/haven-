class_name Player
extends CharacterBody2D

const RUN_ANIMATION_THRESHOLD := 20.0

signal health_changed(current: int)
signal died

@export var gravity := 2400.0
@export var acceleration := 3000.0
@export var air_acceleration := 1800.0
@export var friction := 4000.0
@export var air_friction := 200.0
@export var jump_strength := 1200.0
@export var max_speed := 600.0

@export var max_health := 5

@export var camera_limit_left := -10000000
@export var camera_limit_top := -10000000
@export var camera_limit_right := 10000000
@export var camera_limit_bottom := 10000000

@onready var camera_2d: Camera2D = $Camera2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var health: int
var facing_direction := 1.0
var is_dead := false
var _camera_frozen := false
var _camera_smoothing_enabled := true


func _ready() -> void:
	health = max_health

	_camera_smoothing_enabled = camera_2d.position_smoothing_enabled
	camera_2d.limit_left = camera_limit_left
	camera_2d.limit_top = camera_limit_top
	camera_2d.limit_right = camera_limit_right
	camera_2d.limit_bottom = camera_limit_bottom
	camera_2d.top_level = true
	camera_2d.global_position = global_position
	camera_2d.reset_smoothing()
	camera_2d.force_update_scroll()

	sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	var camera_center := camera_2d.get_screen_center_position()
	var grounded := is_on_floor()

	if is_dead:
		_apply_death_physics(delta)
		_update_camera(camera_center)
		return

	var direction := Input.get_axis("left", "right")
	var jumping := grounded and Input.is_action_just_pressed("jump")

	if not is_zero_approx(direction):
		facing_direction = signf(direction)

	var airborne := not grounded or jumping
	var current_acceleration := air_acceleration if airborne else acceleration
	var current_friction := air_friction if airborne else friction

	if not is_zero_approx(direction):
		velocity.x = move_toward(
			velocity.x,
			max_speed * direction,
			current_acceleration * delta
		)
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_friction * delta)

	if jumping:
		velocity.y = -jump_strength
	elif not grounded:
		velocity.y += gravity * delta

	move_and_slide()
	_update_camera(camera_center)
	_update_animation()


func _apply_death_physics(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()


# The camera holds its last grounded position while airborne, so jumping
# does not drag the view up and down with the player.
func _update_camera(previous_center: Vector2) -> void:
	if is_on_floor():
		camera_2d.position_smoothing_enabled = _camera_smoothing_enabled
		camera_2d.global_position = global_position
		_camera_frozen = false
	elif not _camera_frozen:
		camera_2d.position_smoothing_enabled = false
		camera_2d.global_position = previous_center
		camera_2d.reset_smoothing()
		_camera_frozen = true


func _update_animation() -> void:
	sprite.flip_h = facing_direction < 0.0

	if not is_on_floor():
		_play("jump")
	elif absf(velocity.x) > RUN_ANIMATION_THRESHOLD:
		_play("run")
	else:
		_play("idle")


func _play(animation_name: StringName) -> void:
	if sprite.animation != animation_name:
		sprite.play(animation_name)


func _on_animation_finished() -> void:
	if sprite.animation == &"death":
		died.emit()


func take_damage(amount: int) -> void:
	if is_dead:
		return

	health = maxi(health - amount, 0)
	health_changed.emit(health)

	if health == 0:
		_die()


func _die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	sprite.animation = &"death"
	sprite.frame = 0
	sprite.play(&"death")
