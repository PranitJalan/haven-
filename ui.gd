extends CanvasLayer

const PIP_SIZE := Vector2(26, 26)
const PIP_FULL := Color(0.35, 0.85, 1.0)
const PIP_EMPTY := Color(0.13, 0.17, 0.22)
const WIN_COLOR := Color(0.45, 0.95, 0.8)
const LOSE_COLOR := Color(0.95, 0.35, 0.4)

signal restart_requested

@onready var pips: HBoxContainer = $Health
@onready var end_screen: Control = $EndScreen
@onready var title: Label = $EndScreen/Center/Title
@onready var restart_button: Button = $EndScreen/Center/RestartButton


func _ready() -> void:
	end_screen.hide()
	restart_button.pressed.connect(func() -> void: restart_requested.emit())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		restart_requested.emit()


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


func show_result(won: bool) -> void:
	title.text = "You Win" if won else "You Lost"
	title.modulate = WIN_COLOR if won else LOSE_COLOR
	end_screen.show()
	restart_button.grab_focus()
