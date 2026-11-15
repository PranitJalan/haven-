extends Node

const MAX_UPGRADE := 3

# Coins banked from cleared levels. Coins picked up in the level you are
# currently playing stay with the level until you clear it.
var banked_coins := 0
var pending_next: PackedScene = null

var shield_level := 0
var health_level := 0
var reflect_level := 0
var katana_level := 0


func reset() -> void:
	banked_coins = 0
	pending_next = null
	shield_level = 0
	health_level = 0
	reflect_level = 0
	katana_level = 0


func upgrade_cost(current_level: int) -> int:
	return 6 + current_level * 6


func level_of(key: String) -> int:
	match key:
		"shield": return shield_level
		"health": return health_level
		"reflect": return reflect_level
		"katana": return katana_level
	return 0


func buy(key: String) -> bool:
	var current := level_of(key)

	if current >= MAX_UPGRADE:
		return false

	var cost := upgrade_cost(current)

	if banked_coins < cost:
		return false

	banked_coins -= cost

	match key:
		"shield": shield_level += 1
		"health": health_level += 1
		"reflect": reflect_level += 1
		"katana": katana_level += 1

	return true


func bonus_health() -> int:
	return health_level


func bonus_reflect() -> int:
	return reflect_level


func shield_bonus_energy() -> float:
	return shield_level * 0.6


func shield_bonus_recharge() -> float:
	return shield_level * 0.25


func katana_bonus_damage() -> int:
	return katana_level


func katana_cooldown_scale() -> float:
	return 1.0 - katana_level * 0.12
