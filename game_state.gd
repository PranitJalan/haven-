extends Node

# Coins banked from levels the player has already cleared. Coins picked up
# in the level you are currently playing are tracked by the level itself,
# so dying and retrying does not bank them.
var banked_coins := 0


func reset() -> void:
	banked_coins = 0
