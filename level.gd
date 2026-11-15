extends Node2D

# Falling below this means the player has left the map.
const FALL_LIMIT := 900.0

@export var level_title := "Level 1"
@export var level_number := 1
@export var is_boss_level := false
@export var next_level: PackedScene

@onready var player: Player = $World/Player
# Hand built levels may not have a portal; those finish as soon as the
# last machine falls.
@onready var portal: Portal = get_node_or_null("World/Portal") as Portal
@onready var ui: CanvasLayer = $UI

var _living_enemies := 0
var _coins := 0
var _total_coins := 0
var _finished := false
var _respawn_position := Vector2.ZERO


func _ready() -> void:
	_respawn_position = player.global_position

	if is_boss_level:
		Music.play_warden()
	else:
		Music.play_forest()

	ui.set_level_title(level_title)
	ui.build_health(player.max_health)
	ui.set_health(player.health)
	ui.show_story(Story.beat_for(level_number))
	ui.restart_requested.connect(_restart)
	ui.menu_requested.connect(_to_menu)

	player.health_changed.connect(ui.set_health)
	player.died.connect(_on_player_died)
	if portal != null:
		portal.entered.connect(_complete)

	for node in get_tree().get_nodes_in_group("pickups"):
		var pickup := node as Pickup

		if pickup == null:
			continue

		if pickup.kind == Pickup.Kind.COIN:
			_total_coins += 1

		pickup.collected.connect(_on_pickup_collected)

	_refresh_coins()

	for node in get_tree().get_nodes_in_group("tablets"):
		var tablet := node as Tablet

		if tablet != null:
			tablet.inscription_read.connect(_on_inscription)

	for node in get_tree().get_nodes_in_group("shrines"):
		var shrine := node as Shrine

		if shrine != null:
			shrine.used.connect(_on_shrine_used.bind(shrine.global_position))

	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy

		if enemy == null:
			continue

		_living_enemies += 1
		enemy.died.connect(_on_enemy_died)

	if _living_enemies == 0:
		_open_portal()


func _physics_process(_delta: float) -> void:
	if _finished or player.is_dead:
		return

	if player.global_position.y > FALL_LIMIT:
		respawn_player()


# Lanterns and shrines move the point you come back to.
func set_checkpoint(point: Vector2) -> void:
	_respawn_position = point


func respawn_player() -> void:
	player.take_damage(1)

	if player.is_dead:
		return

	player.global_position = _respawn_position
	player.velocity = Vector2.ZERO
	player.camera_2d.global_position = _respawn_position
	player.camera_2d.reset_smoothing()
	ui.show_banner("The grove pulls you back")


func _refresh_coins() -> void:
	ui.set_coins(Game.banked_coins + _coins, Game.banked_coins + _total_coins)


func _on_pickup_collected(kind: Pickup.Kind) -> void:
	if kind != Pickup.Kind.COIN:
		return

	_coins += 1
	_refresh_coins()


func _on_inscription(text: String) -> void:
	Game.inscriptions += 1
	ui.show_story(text)


func _on_shrine_used(shrine_position: Vector2) -> void:
	player.heal_full()
	set_checkpoint(shrine_position)
	ui.show_banner("The root remembers you")


func _on_enemy_died() -> void:
	_living_enemies -= 1

	if _living_enemies <= 0:
		_open_portal()


func _open_portal() -> void:
	if portal == null:
		_complete()
		return

	portal.open()
	ui.show_banner("The way is open")


func _on_player_died() -> void:
	ui.show_lost()
	get_tree().paused = true


# Reached by walking into the portal once every machine is down.
func _complete() -> void:
	if _finished:
		return

	_finished = true

	# Coins only bank on a cleared level, so retrying cannot farm them.
	Game.banked_coins += _coins
	get_tree().paused = false

	if next_level == null:
		ui.show_ending(Story.ENDING)
		get_tree().paused = true
		return

	if is_boss_level:
		# First Warden down grants the second jump.
		if not Game.has_double_jump:
			Game.has_double_jump = true
			Game.just_unlocked = "You can jump again in mid-air."

		Game.pending_next = next_level
		get_tree().change_scene_to_file("res://upgrade_menu.tscn")
		return

	get_tree().change_scene_to_packed(next_level)


func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _to_menu() -> void:
	get_tree().paused = false
	Game.reset()
	get_tree().change_scene_to_file("res://main_menu.tscn")
