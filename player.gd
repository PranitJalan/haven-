extends CharacterBody2D

@export var gravity := 2400.0
@export var acceleration := 3000.0
@export var air_acceleration := 1800.0
@export var friction := 4000.0
@export var air_friction := 200.0
@export var jump_strength := 1200.0
@export var max_speed := 600.0
@onready var camera_2d: Camera2D = $Camera2D
@onready var icon: AnimatedSprite2D = $Icon

var _camera_frozen := false
var _camera_smoothing_enabled := true

func _ready() -> void:
	# Keep the camera independent of the player's transform, including in the air.
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
	var airborne := not grounded or jumping
	var current_acceleration := air_acceleration if airborne else acceleration
	var current_friction := air_friction if airborne else friction

	if not is_zero_approx(direction):
		velocity.x = move_toward(velocity.x, max_speed * direction, current_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_friction * delta)

	if jumping:
		velocity.y = -jump_strength
	elif not grounded:
		velocity.y += gravity * delta
	
	
	move_and_slide()
	_update_camera(camera_center)
func animate(direction):
	if direction == 0:
		icon.play("default")
	else:
		if direction == -1:
			icon.flip_h = true
		else:
			icon.flip_h = false
		icon.play("run")
	
	
func _update_camera(previous_center: Vector2) -> void:
	# Check the floor after moving so jumps, ledges, and landings update immediately.
	if is_on_floor():
		camera_2d.position_smoothing_enabled = _camera_smoothing_enabled
		camera_2d.global_position = global_position
		_camera_frozen = false
	elif not _camera_frozen:
		# Freeze the visible center, including any unfinished smoothing from running.
		camera_2d.position_smoothing_enabled = false
		camera_2d.global_position = previous_center
		camera_2d.reset_smoothing()
		_camera_frozen = true
