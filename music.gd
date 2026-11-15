extends Node

const FOREST := preload("res://Music/forest_theme.ogg")
const WARDEN := preload("res://Music/warden_theme.ogg")

const LEVEL_DB := -14.0
const FADE_TIME := 1.2

var _player: AudioStreamPlayer
var _current: AudioStream = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_player = AudioStreamPlayer.new()
	_player.bus = &"Master"
	_player.volume_db = LEVEL_DB
	add_child(_player)


# Switching to the track that is already playing leaves it alone, so the
# music keeps running across scene changes instead of restarting.
func play(stream: AudioStream) -> void:
	if stream == _current and _player.playing:
		return

	_current = stream

	if stream is AudioStreamOggVorbis:
		stream.loop = true

	_player.stream = stream
	_player.volume_db = -40.0
	_player.play()

	var tween := create_tween()
	tween.tween_property(_player, "volume_db", LEVEL_DB, FADE_TIME)


func play_forest() -> void:
	play(FOREST)


func play_warden() -> void:
	play(WARDEN)


func stop() -> void:
	_current = null
	_player.stop()
