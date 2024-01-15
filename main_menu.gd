extends Node

@onready var start_button = %StartButton
@onready var animation_player = %AnimationPlayer

func _ready():
	start_button.show()
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	start_button.hide()
	animation_player.play("start_game")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://test_level.tscn")
