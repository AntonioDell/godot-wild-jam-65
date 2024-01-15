@tool
extends Control

@export var player: Player

@onready var expand_settings_checkbox = %ExpandSettingsCheckbox
@onready var settings_list = %SettingsList


func _ready():
	# Settings controls
	%ExpandSettingsCheckbox.toggled.connect(func(toggled_on: bool): %SettingsList.visible = toggled_on)
	%SettingsList.visible = expand_settings_checkbox.button_pressed
	
	if Engine.is_editor_hint(): return
	
	# Range based controls
	%WalkingSpeed.value_changed.connect(func(value: float): player.walking_speed = value)
	%WalkingSpeed.value = player.walking_speed
	%WalkingSlowdown.value_changed.connect(func(value: float): player.walking_slowdown = value)
	%WalkingSlowdown.value = player.walking_slowdown
	%MaxGravity.value_changed.connect(func(value: float): player.max_gravity = value)
	%MaxGravity.value = player.max_gravity
	%JumpVerticalAccelerationDuration.value_changed.connect(func(value: float): player.jump.max_jump_duration  = value)
	%JumpVerticalAccelerationDuration.value = player.jump.max_jump_duration 
	%JumpMaxCoyoteTime.value_changed.connect(func(value: float): player.jump.max_coyote_time = value)
	%JumpMaxCoyoteTime.value = player.jump.max_coyote_time
	%JumpMaxRememberTime.value_changed.connect(func(value: float): player.jump.max_jump_remember_time = value)
	%JumpMaxRememberTime.value = player.jump.max_jump_remember_time
	%JumpMaxJumpSpeed.value_changed.connect(func(value: float): player.jump.max_jump_speed = value)
	%JumpMaxJumpSpeed.value = player.jump.max_jump_speed
	%RocketMaxChargeTime.value_changed.connect(func(value: float): player.rocket.max_charge_time_seconds = value)
	%RocketMaxChargeTime.value = player.rocket.max_charge_time_seconds
	%RocketMinCharge.value_changed.connect(func(value: float): player.rocket.min_charge = value)
	%RocketMinCharge.value = player.rocket.min_charge
	%RocketMaxVerticalAccelerationDuration.value_changed.connect(func(value: float): player.rocket.max_vertical_acceleration_duration = value)
	%RocketMaxVerticalAccelerationDuration.value = player.rocket.max_vertical_acceleration_duration
	%RocketMaxVerticalSpeed.value_changed.connect(func(value: float): player.rocket.max_vertical_speed = value)
	%RocketMaxVerticalSpeed.value = player.rocket.max_vertical_speed
	%RocketMaxOverloadTime.value_changed.connect(func(value: float): player.rocket.max_overload_time = value)
	%RocketMaxOverloadTime.value = player.rocket.max_overload_time


func _on_expand_settings_checkbox_toggled(toggled_on: bool):
	settings_list.visible = toggled_on
