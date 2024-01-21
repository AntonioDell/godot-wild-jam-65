extends Node

@onready var start_button = %StartButton
@onready var animation_player = %AnimationPlayer
@onready var volume_setting = %VolumeSetting
@onready var volume_slider = %Volume


func _ready():
	start_button.show()
	start_button.pressed.connect(_on_start_button_pressed)
	AudioManager.play_music(0)
	volume_slider.value = GameState.settings.volume

func _on_start_button_pressed():
	start_button.hide()
	volume_setting.hide()
	animation_player.play("start_game")

func _hacky_hack():
	is_game_started = true

var is_game_started = false:
	set(value):
		is_game_started = true
		GameState.start_game()


func _on_volume_value_changed(value):
	GameState.change_setting("volume", value)
