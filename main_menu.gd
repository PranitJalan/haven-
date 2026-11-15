extends Control

@onready var start_button: Button = $Center/Start
@onready var credits_button: Button = $Center/Credits
@onready var quit_button: Button = $Center/Quit
@onready var intro: Label = $Center/Intro


func _ready() -> void:
	Game.reset()
	intro.text = Story.INTRO
	start_button.pressed.connect(_start)
	credits_button.pressed.connect(
		func() -> void: get_tree().change_scene_to_file("res://credits.tscn")
	)
	quit_button.pressed.connect(func() -> void: get_tree().quit())
	start_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_start()


func _start() -> void:
	get_tree().change_scene_to_file("res://level_1.tscn")
