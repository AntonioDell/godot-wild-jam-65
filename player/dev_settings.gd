@tool
extends Control


@onready var expand_settings_checkbox = %ExpandSettingsCheckbox
@onready var settings_list = %SettingsList

func _ready():
	expand_settings_checkbox.toggled.connect(_on_expand_settings_checkbox_toggled)
	_on_expand_settings_checkbox_toggled(expand_settings_checkbox.button_pressed)


func _on_expand_settings_checkbox_toggled(toggled_on: bool):
	settings_list.visible = toggled_on
