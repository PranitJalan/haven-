extends Control

const UPGRADES := [
	{"key": "shield", "title": "Shield Cell", "detail": "Hold the shield longer, recharge faster"},
	{"key": "health", "title": "Heart Shard", "detail": "One more heart"},
	{"key": "reflect", "title": "Return Force", "detail": "Rockets you send back hit harder"},
	{"key": "katana", "title": "Edge Hone", "detail": "Katana cuts harder and swings sooner"},
]

@onready var rows: VBoxContainer = $Center/Rows
@onready var balance: Label = $Center/Balance
@onready var continue_button: Button = $Center/Continue


func _ready() -> void:
	continue_button.pressed.connect(_continue)
	_rebuild()
	_show_unlock()
	continue_button.grab_focus()


func _show_unlock() -> void:
	var unlock: Label = $Center/Unlock
	unlock.text = Game.just_unlocked
	unlock.visible = not Game.just_unlocked.is_empty()
	Game.just_unlocked = ""


func _rebuild() -> void:
	for child in rows.get_children():
		rows.remove_child(child)
		child.free()

	for upgrade in UPGRADES:
		rows.add_child(_build_row(upgrade))

	balance.text = "%d coins" % Game.banked_coins


func _build_row(upgrade: Dictionary) -> HBoxContainer:
	var key: String = upgrade["key"]
	var level := Game.level_of(key)
	var maxed := level >= Game.MAX_UPGRADE

	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(620, 54)
	row.add_theme_constant_override("separation", 14)

	var label := Label.new()
	label.text = "%s  %s\n%s" % [upgrade["title"], _pips(level), upgrade["detail"]]
	label.add_theme_font_size_override("font_size", 15)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var button := Button.new()
	button.custom_minimum_size = Vector2(150, 44)
	button.add_theme_font_size_override("font_size", 16)

	if maxed:
		button.text = "Maxed"
		button.disabled = true
	else:
		var cost := Game.upgrade_cost(level)
		button.text = "Buy  %d" % cost
		button.disabled = Game.banked_coins < cost
		button.pressed.connect(func() -> void: _buy(key))

	row.add_child(button)
	return row


func _pips(level: int) -> String:
	var out := ""

	for i in Game.MAX_UPGRADE:
		out += "[#]" if i < level else "[ ]"

	return out


func _buy(key: String) -> void:
	if Game.buy(key):
		_rebuild()


func _continue() -> void:
	if Game.pending_next == null:
		get_tree().change_scene_to_file("res://main_menu.tscn")
		return

	var next := Game.pending_next
	Game.pending_next = null
	get_tree().change_scene_to_packed(next)
