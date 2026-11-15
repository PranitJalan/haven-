class_name Shield
extends Area2D

const ARC_RADIUS := 95.0
const ARC_HALF_ANGLE := PI / 3.0

const COLOR_READY := Color(0.3, 0.8, 1.0)
const COLOR_DRAINED := Color(1.0, 0.68, 0.25)
const COLOR_LOCKED := Color(1.0, 0.3, 0.35)

@export var max_energy := 2.0
@export var recharge_rate := 0.8
@export var lockout_time := 1.3

@onready var player: Player = get_parent()

var energy: float
var is_shielding := false
var is_locked := false

var _lockout_remaining := 0.0
var _pulse := 0.0


func _ready() -> void:
	energy = max_energy
	monitoring = false
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	rotation = 0.0 if player.facing_direction > 0.0 else PI
	_pulse += delta

	_update_energy(delta)

	var wants_shield := (
		Input.is_action_pressed("shield")
		and not is_locked
		and not player.is_dead
	)

	if wants_shield != is_shielding:
		is_shielding = wants_shield
		monitoring = wants_shield

	queue_redraw()


func _update_energy(delta: float) -> void:
	if is_locked:
		_lockout_remaining -= delta

		if _lockout_remaining <= 0.0:
			is_locked = false
			energy = max_energy * 0.5

		return

	if is_shielding:
		energy -= delta

		if energy <= 0.0:
			energy = 0.0
			_lock()
	else:
		energy = minf(energy + recharge_rate * delta, max_energy)


func _lock() -> void:
	is_locked = true
	is_shielding = false
	monitoring = false
	_lockout_remaining = lockout_time


# The arc doubles as the energy meter: it dims and shifts toward amber as
# energy drains, then flashes red while locked out.
func _draw() -> void:
	var ratio := energy / max_energy
	var color: Color
	var width: float

	if is_locked:
		color = COLOR_LOCKED
		color.a = 0.35 + 0.25 * sin(_pulse * 18.0)
		width = 5.0
	elif is_shielding:
		color = COLOR_DRAINED.lerp(COLOR_READY, ratio)
		color.a = 0.95
		width = 10.0
	else:
		color = COLOR_DRAINED.lerp(COLOR_READY, ratio)
		color.a = 0.22
		width = 4.0

	draw_arc(
		Vector2.ZERO,
		ARC_RADIUS,
		-ARC_HALF_ANGLE,
		ARC_HALF_ANGLE,
		24,
		color,
		width
	)


func refill() -> void:
	energy = max_energy
	is_locked = false
	_lockout_remaining = 0.0


func _on_area_entered(area: Area2D) -> void:
	var projectile := area as EnemyProjectile

	if projectile != null:
		projectile.reflect()
		player.shake_camera(5.0)
