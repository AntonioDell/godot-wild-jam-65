class_name AudioSettings
extends Resource


signal volume_sfx_changed(new_value: float)
signal volume_music_changed(new_value: float)
signal mute_sfx_changed(new_value: bool)
signal mute_music_changed(new_value: bool)
signal mute_all_changed(new_value: bool)


const MAX_VOLUME_DB = 0.0
const MIN_VOLUME_DB = -80.0


@export var volume_sfx: float = .7:
	set(value):
		if volume_sfx == value: return
		volume_sfx_changed.emit(value)
		volume_sfx = value
@export var mute_sfx: bool = false:
	set(value):
		if mute_sfx == value: return
		mute_sfx_changed.emit(value)
		mute_sfx = value

@export var volume_music: float = .7:
	set(value):
		if volume_music == value: return
		volume_music_changed.emit(value)
		volume_music = value
@export var mute_music: bool = false:
	set(value):
		if mute_music == value: return
		mute_music_changed.emit(value)
		mute_music = value

@export var mute_all: bool = false:
	set(value):
		if mute_all == value: return
		mute_all_changed.emit(value)
		mute_all = value

	
