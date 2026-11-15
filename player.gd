class_name Player
extends CharacterBody2D

const RUN_ANIMATION_THRESHOLD := 20.0
const SPRITE_SCALE := Vector2(0.55, 0.55)

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
@export var invincibility_time := 0.9

@export var camera_limit_left := -10000000
@export var camera_limit_top := -10000000
@export var camera_limit_right := 10000000
@export var camera_limit_bottom := 10000000

@export var jump_puff_scene: PackedScene
@export var land_puff_scene: PackedScene

@onready var camera_2d: Camera2D = $Camera2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shield: Shield = $Shield
@onready var run_dust: CPUParticles2D = $RunDust

var health: int
var facing_direction := 1.0
var is_dead := false

var _invincible_remaining := 0.0
var _shake_strength := 0.0
var _was_grounded := true
var _camera_frozen := false
var _camera_smoothing_enabled := true


func _ready() -> void:
	max_health += Game.bonus_health()
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

	_invincible_remaining = maxf(_invincible_remaining - delta, 0.0)

	if is_dead:
		run_dust.emitting = false
		_apply_death_physics(delta)
		_update_camera(camera_center)
		_update_shake(delta)
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
		_squash(Vector2(0.82, 1.2))
		_spawn_puff(jump_puff_scene)
	elif not grounded:
		velocity.y += gravity * delta

	move_and_slide()

	if is_on_floor() and not _was_grounded:
		_land()

	_was_grounded = is_on_floor()

	run_dust.emitting = (
		is_on_floor()
		and absf(velocity.x) > 150.0
	)

	_update_camera(camera_center)
	_update_shake(delta)
	_update_animation()


func _apply_death_physics(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()


func _land() -> void:
	_squash(Vector2(1.25, 0.76))
	shake_camera(3.0)
	_spawn_puff(land_puff_scene)


func _spawn_puff(scene: PackedScene) -> void:
	if scene == null:
		return

	var puff := scene.instantiate() as Node2D

	if puff == null:
		return

	get_tree().current_scene.add_child(puff)
	puff.global_position = global_position + Vector2(0, 55)

	get_tree().create_timer(1.6).timeout.connect(
		func() -> void:
			if is_instance_valid(puff):
				puff.queue_free()
	)


func _squash(amount: Vector2) -> void:
	sprite.scale = SPRITE_SCALE * amount

	var tween := create_tween()
	tween.tween_property(sprite, "scale", SPRITE_SCALE, 0.2)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)


func refill_shield() -> void:
	shield.refill()


func shake_camera(strength: float) -> void:
	_shake_strength = maxf(_shake_strength, strength)


func _update_shake(delta: float) -> void:
	if _shake_strength <= 0.0:
		camera_2d.offset = Vector2.ZERO
		return

	_shake_strength = maxf(_shake_strength - 45.0 * delta, 0.0)
	camera_2d.offset = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	) * _shake_strength


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

	if _invincible_remaining > 0.0:
		sprite.modulate.a = 0.45 + 0.55 * absf(sin(_invincible_remaining * 30.0))
	else:
		sprite.modulate.a = 1.0

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
	if is_dead or _invincible_remaining > 0.0:
		return

	health = maxi(health - amount, 0)
	health_changed.emit(health)

	_invincible_remaining = invincibility_time
	_flash()
	shake_camera(9.0)

	if health == 0:
		_die()


func _flash() -> void:
	sprite.modulate = Color(7.0, 7.0, 7.0)

	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)


func _die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	sprite.modulate = Color.WHITE
	sprite.modulate.a = 1.0
	sprite.animation = &"death"
	sprite.frame = 0
	sprite.play(&"death")
