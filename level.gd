extends Node2D

@onready var player: Player = $World/Player
@onready var ui: CanvasLayer = $UI

var _living_enemies := 0


func _ready() -> void:
	ui.build_health(player.max_health)
	ui.set_health(player.health)
	ui.restart_requested.connect(_restart)

	player.health_changed.connect(ui.set_health)
	player.died.connect(_on_player_died)

	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy

		if enemy == null:
			continue

		_living_enemies += 1
		enemy.died.connect(_on_enemy_died)


func _on_enemy_died() -> void:
	_living_enemies -= 1

	if _living_enemies <= 0:
		_end_game(true)


func _on_player_died() -> void:
	_end_game(false)


func _end_game(won: bool) -> void:
	ui.show_result(won)
	get_tree().paused = true


func _restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
