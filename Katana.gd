extends Area2D

const REACH := 150.0
const SWEEP := PI / 1.7

@export var damage := 1
@export var swing_time := 0.24
@export var cooldown := 0.42

@onready var player: Player = get_parent()
@onready var blade: Sprite2D = $Blade

var _swing_remaining := 0.0
var _cooldown_remaining := 0.0


func _ready() -> void:
	damage += Game.katana_bonus_damage()
	cooldown *= Game.katana_cooldown_scale()
	monitoring = false
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	rotation = 0.0 if player.facing_direction > 0.0 else PI
	_update_blade()

	_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)

	if _swing_remaining > 0.0:
		_swing_remaining -= delta

		if _swing_remaining <= 0.0:
			monitoring = false
	elif _can_swing():
		_start_swing()

	queue_redraw()


func _can_swing() -> bool:
	return (
		Input.is_action_just_pressed("attack")
		and _cooldown_remaining <= 0.0
		and not player.is_dead
	)


func _start_swing() -> void:
	_swing_remaining = swing_time
	_cooldown_remaining = cooldown
	monitoring = true


func _swing_progress() -> float:
	return 1.0 - (_swing_remaining / swing_time)


func _update_blade() -> void:
	if _swing_remaining <= 0.0:
		blade.visible = false
		return

	var t := _swing_progress()
	blade.visible = true
	blade.rotation = lerpf(-SWEEP * 0.55, SWEEP * 0.45, t)
	blade.modulate.a = clampf(1.3 - t, 0.0, 1.0)


# A crescent that sweeps down through the arc and fades as it goes.
func _draw() -> void:
	if _swing_remaining <= 0.0:
		return

	var t := _swing_progress()
	var start := lerpf(-SWEEP * 0.5, SWEEP * 0.25, t)
	var end := start + SWEEP * 0.55
	var alpha := 1.0 - t * t

	draw_arc(
		Vector2.ZERO,
		REACH,
		start,
		end,
		20,
		Color(0.92, 0.98, 1.0, alpha),
		7.0
	)

	var blade_angle := (start + end) * 0.5
	draw_line(
		Vector2.ZERO,
		Vector2.RIGHT.rotated(blade_angle) * REACH,
		Color(0.85, 0.95, 1.0, alpha * 0.9),
		4.0
	)


func _on_area_entered(area: Area2D) -> void:
	var projectile := area as EnemyProjectile

	if projectile != null:
		projectile.cut()
		player.shake_camera(4.0)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.call("take_damage", damage, true)
		player.shake_camera(7.0)
