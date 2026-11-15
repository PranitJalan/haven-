
extends CharacterBody2D

@export var gravity := 2400.0
@export var acceleration := 3000.0
@export var air_acceleration := 1800.0
@export var friction := 4000.0
@export var air_friction := 200.0
@export var jump_strength := 1200.0
@export var max_speed := 600.0

@export var health := 5

@onready var camera_2d: Camera2D = $Camera2D

var facing_direction := 1.0
var _camera_frozen := false
var _camera_smoothing_enabled := true


func _ready() -> void:
	_camera_smoothing_enabled = camera_2d.position_smoothing_enabled
	camera_2d.top_level = true
	camera_2d.global_position = global_position
	camera_2d.reset_smoothing()
	camera_2d.force_update_scroll()


func _physics_process(delta: float) -> void:
	var camera_center := camera_2d.get_screen_center_position()
	var grounded := is_on_floor()

	var direction := Input.get_axis("Left", "right")
	var jumping := grounded and Input.is_action_just_pressed("Jump")

	if not is_zero_approx(direction):
		facing_direction = sign(direction)

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
		velocity.x = move_toward(
			velocity.x,
			0.0,
			current_friction * delta
		)

	if jumping:
		velocity.y = -jump_strength
	elif not grounded:
		velocity.y += gravity * delta

	move_and_slide()
	_update_camera(camera_center)


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


func take_damage(amount: int) -> void:
	health -= amount
	print("Player health: ", health)

	if health <= 0:
		print("Player defeated!")
