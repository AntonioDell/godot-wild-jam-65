extends Node

@onready var start_button = %StartButton
@onready var animation_player = %AnimationPlayer


func _ready():
	start_button.show()
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	start_button.hide()
	animation_player.play("start_game")

func _hacky_hack():
	is_game_started = true

var is_game_started = false:
	set(value):
		is_game_started = true
		GameState.start_game()
