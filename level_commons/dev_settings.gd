@tool
extends Node

signal to_end_button_clicked

@onready var expand_settings_checkbox = %ExpandSettingsCheckbox
@onready var settings_list = %SettingsList

var player

func _ready():
	# Settings controls
	%ExpandSettingsCheckbox.toggled.connect(func(toggled_on: bool): %SettingsList.visible = toggled_on)
	%SettingsList.visible = expand_settings_checkbox.button_pressed
	
	if Engine.is_editor_hint(): return
	player = get_tree().get_first_node_in_group("player")
	# Shortcuts
	%ToEndButton.pressed.connect(func(): to_end_button_clicked.emit())
	
	return
	if not player:
		push_error("%s configuration error: No player in tree")
