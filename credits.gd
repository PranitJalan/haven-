extends Control

const TEXT := """— Code —
Swastik  ·  Pranit

— Art —

Particles, HUD, pickups and terrain tiles
Kenney  ·  kenney.nl  ·  CC0

Blade sprite
Wenrexa, via OpenGameArt  ·  CC0

Ghost and Robot characters
by MJ

Parallax Forest Background (Seamless)
author unidentified

The character and background packs reached us through a
third-party redistribution and we could not verify their
original source or licence. Credit goes to the artists
named above. If you made these and want them removed,
get in touch and we will take them down.

— Engine —
Godot 4.7"""

@onready var body: Label = $Center/Body
@onready var back_button: Button = $Center/Back


func _ready() -> void:
	body.text = TEXT
	back_button.pressed.connect(_back)
	back_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		_back()


func _back() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
