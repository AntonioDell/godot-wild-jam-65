extends Control


@onready var mute_all_toggle: CheckButton = %MuteAllToggle
@onready var volume_music_slider: HSlider = %VolumeMusicSlider
@onready var mute_music_toggle: CheckButton = %MuteMusicToggle
@onready var volume_sfx_slider: HSlider = %VolumeSfxSlider
@onready var mute_sfx_toggle: CheckButton = %MuteSfxToggle
@onready var audio_settings: AudioSettings = GlobalSettings.audio_settings


func _ready():
	_on_volume_music_slider_value_changed(audio_settings.volume_music)
	_on_volume_sfx_slider_value_changed(audio_settings.volume_sfx)
	_on_mute_music_toggle_toggled(audio_settings.mute_music)
	_on_mute_sfx_toggle_toggled(audio_settings.mute_sfx)
	_on_mute_all_toggle_toggled(audio_settings.mute_all)

func _on_mute_all_toggle_toggled(toggled_on: bool):
	audio_settings.mute_all = toggled_on
	mute_music_toggle.disabled = toggled_on
	mute_sfx_toggle.disabled = toggled_on
	_enable_music_slider()
	_enable_sfx_slider()

func _on_volume_music_slider_value_changed(value: float):
	audio_settings.volume_music = value

func _on_mute_music_toggle_toggled(toggled_on: bool):
	audio_settings.mute_music = toggled_on
	_enable_music_slider()

func _on_volume_sfx_slider_value_changed(value: float):
	audio_settings.volume_music = value

func _on_mute_sfx_toggle_toggled(toggled_on: bool):
	audio_settings.mute_sfx = toggled_on
	_enable_sfx_slider()

func _enable_music_slider():
	volume_music_slider.editable = not mute_all_toggle.button_pressed and not mute_music_toggle.button_pressed

func _enable_sfx_slider():
	volume_sfx_slider.editable = not mute_all_toggle.button_pressed and not mute_sfx_toggle.button_pressed

func _on_back_to_settings_btn_pressed():
	# TODO: Go  back to settings smh idk
	pass 
