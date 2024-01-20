extends StaticBody2D

@export var is_open = false:
	set(value):
		if is_open == value: return
		is_open = value
		_update_door_state()

@onready var animation_player = %AnimationPlayer


func _ready():
	_update_door_state()


func open():
	animation_player.play("opens")

func close():
	animation_player.play("closes")

func _update_door_state():
	if not animation_player: return
	
	if is_open:
		animation_player.play("opens")
	else:
		animation_player.play("closes")
