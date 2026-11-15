extends Node2D

@export var level_title := "Level 1"
@export var next_level: PackedScene

@onready var player: Player = $World/Player
@onready var ui: CanvasLayer = $UI

var _living_enemies := 0
var _coins := 0
var _total_coins := 0
var _won := false


func _ready() -> void:
	ui.set_level_title(level_title)
	ui.build_health(player.max_health)
	ui.set_health(player.health)
	ui.restart_requested.connect(_restart)
	ui.next_requested.connect(_advance)

	player.health_changed.connect(ui.set_health)
	player.died.connect(_on_player_died)

	for node in get_tree().get_nodes_in_group("pickups"):
		var pickup := node as Pickup

		if pickup == null:
			continue

		if pickup.kind == Pickup.Kind.COIN:
			_total_coins += 1

		pickup.collected.connect(_on_pickup_collected)

	_refresh_coins()

	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy

		if enemy == null:
			continue

		_living_enemies += 1
		enemy.died.connect(_on_enemy_died)


func _refresh_coins() -> void:
	ui.set_coins(Game.banked_coins + _coins, Game.banked_coins + _total_coins)


func _on_pickup_collected(kind: Pickup.Kind) -> void:
	if kind != Pickup.Kind.COIN:
		return

	_coins += 1
	_refresh_coins()


func _on_enemy_died() -> void:
	_living_enemies -= 1

	if _living_enemies <= 0:
		_end_game(true)


func _on_player_died() -> void:
	_end_game(false)


func _end_game(won: bool) -> void:
	_won = won

	# Coins only bank once the level is actually cleared, so retrying a
	# level you died on cannot farm them.
	if won:
		Game.banked_coins += _coins

	ui.show_result(won, next_level != null)
	get_tree().paused = true


func _restart() -> void:
	get_tree().paused = false

	if _won and next_level == null:
		Game.reset()

	get_tree().reload_current_scene()


func _advance() -> void:
	get_tree().paused = false

	if next_level == null:
		get_tree().reload_current_scene()
		return

	get_tree().change_scene_to_packed(next_level)
