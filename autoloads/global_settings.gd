extends Node

var audio_settings: AudioSettings

func save_settings():
	_save_audio_settings()

func _ready():
	_load_audio_settings()

func _load_audio_settings():
	if audio_settings: return
	
	if ResourceLoader.exists("user://audio_settings.tres"):
		audio_settings = ResourceLoader.load("user://audio_settings.tres") as AudioSettings
	else:
		audio_settings = AudioSettings.new()

func _save_audio_settings():
	ResourceSaver.save(audio_settings, "user://audio_settings.tres")
