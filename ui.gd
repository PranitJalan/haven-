extends CanvasLayer

const WIN_COLOR := Color(0.5, 0.95, 0.82)
const LOSE_COLOR := Color(0.95, 0.35, 0.4)

signal restart_requested
signal menu_requested

@onready var hearts: Control = $Hearts
@onready var coins: Label = $Coins
@onready var level_label: Label = $LevelTitle
@onready var story_card: Label = $StoryCard
@onready var banner: Label = $Banner
@onready var end_screen: Control = $EndScreen
@onready var title: Label = $EndScreen/Center/Title
@onready var body: Label = $EndScreen/Center/Body
@onready var action_button: Button = $EndScreen/Center/ActionButton
@onready var hint: Label = $EndScreen/Center/Hint

var _returns_to_menu := false


func _ready() -> void:
	end_screen.hide()
	story_card.modulate.a = 0.0
	banner.modulate.a = 0.0
	action_button.pressed.connect(_on_button_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		restart_requested.emit()


func _on_button_pressed() -> void:
	if _returns_to_menu:
		menu_requested.emit()
	else:
		restart_requested.emit()


func set_level_title(text: String) -> void:
	level_label.text = text


func build_health(max_health: int) -> void:
	hearts.setup(max_health)


func set_health(current: int) -> void:
	hearts.set_health(current)


func set_coins(collected: int, total: int) -> void:
	coins.text = "%d / %d" % [collected, total]


# Story beat at the start of a level: fades in, holds, fades out.
func show_story(text: String) -> void:
	if text.is_empty():
		return

	story_card.text = text

	var tween := create_tween()
	tween.tween_property(story_card, "modulate:a", 1.0, 0.7)
	tween.tween_interval(3.8)
	tween.tween_property(story_card, "modulate:a", 0.0, 0.9)


func show_banner(text: String) -> void:
	banner.text = text

	var tween := create_tween()
	tween.tween_property(banner, "modulate:a", 1.0, 0.35)
	tween.tween_interval(2.0)
	tween.tween_property(banner, "modulate:a", 0.0, 0.7)


func show_lost() -> void:
	_returns_to_menu = false
	title.text = "You Lost"
	title.modulate = LOSE_COLOR
	body.text = ""
	action_button.text = "Retry"
	hint.text = "or press R"
	end_screen.show()
	action_button.grab_focus()


func show_ending(text: String) -> void:
	_returns_to_menu = true
	title.text = "You Win"
	title.modulate = WIN_COLOR
	body.text = text
	action_button.text = "Return to the grove"
	hint.text = ""
	end_screen.show()
	action_button.grab_focus()
