extends Node

signal developer_settings_changed(new_settings: DeveloperSettings)


var developer_settings: DeveloperSettings:
	set(value):
		developer_settings = value
		developer_settings_changed.emit(developer_settings)

func _ready():
	if ResourceLoader.exists("user://developer_settings.tres"):
		developer_settings = ResourceLoader.load("user://developer_settings.tres") as DeveloperSettings
	else:
		developer_settings = DeveloperSettings.new()
