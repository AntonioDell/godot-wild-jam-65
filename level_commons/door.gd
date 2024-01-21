@tool
extends StaticBody2D
class_name Door

@export var is_open = false:
	set(value):
		if is_open == value: return
		is_open = value
		_update_door_state()

@onready var animation_player = %AnimationPlayer


func _ready():
	_update_door_state()
	


func open():
	AudioManager.play_sfx_door()
	is_open = true

func close():
	AudioManager.play_sfx_door()
	is_open = false

func _update_door_state():
	if not animation_player: return
	
	if is_open:
		animation_player.play("opens")
	else:
		animation_player.play("closes")
