extends CanvasLayer

const PIP_SIZE := Vector2(26, 26)
const PIP_FULL := Color(0.35, 0.85, 1.0)
const PIP_EMPTY := Color(0.13, 0.17, 0.22)
const WIN_COLOR := Color(0.45, 0.95, 0.8)
const LOSE_COLOR := Color(0.95, 0.35, 0.4)

signal restart_requested
signal next_requested

@onready var pips: HBoxContainer = $Health
@onready var coins: Label = $Coins
@onready var level_label: Label = $LevelTitle
@onready var hint: Label = $EndScreen/Center/Hint
@onready var end_screen: Control = $EndScreen
@onready var title: Label = $EndScreen/Center/Title
@onready var restart_button: Button = $EndScreen/Center/RestartButton


func _ready() -> void:
	end_screen.hide()
	restart_button.pressed.connect(_on_button_pressed)


var _has_next := false


func _on_button_pressed() -> void:
	if _has_next:
		next_requested.emit()
	else:
		restart_requested.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		restart_requested.emit()
	elif _has_next and event.is_action_pressed("ui_accept"):
		next_requested.emit()


func set_level_title(text: String) -> void:
	level_label.text = text


func build_health(max_health: int) -> void:
	for child in pips.get_children():
		pips.remove_child(child)
		child.free()

	for i in max_health:
		var pip := ColorRect.new()
		pip.custom_minimum_size = PIP_SIZE
		pip.color = PIP_FULL
		pips.add_child(pip)


func set_health(current: int) -> void:
	var children := pips.get_children()

	for i in children.size():
		var pip := children[i] as ColorRect
		pip.color = PIP_FULL if i < current else PIP_EMPTY


func set_coins(collected: int, total: int) -> void:
	coins.text = "%d / %d" % [collected, total]


func show_result(won: bool, has_next: bool) -> void:
	_has_next = won and has_next

	if not won:
		title.text = "You Lost"
		restart_button.text = "Restart"
	elif has_next:
		title.text = "Level Complete"
		restart_button.text = "Next Level"
	else:
		title.text = "You Win"
		restart_button.text = "Restart"

	title.modulate = WIN_COLOR if won else LOSE_COLOR
	hint.text = "or press Enter" if _has_next else "or press R"

	end_screen.show()
	restart_button.grab_focus()
