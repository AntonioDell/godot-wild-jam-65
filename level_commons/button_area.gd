@tool
extends Area2D
class_name ButtonArea

signal button_pressed

@export var is_pressed = false: 
	set(value):
		is_pressed = value
		_play_animation()

@onready var animation_player = %AnimationPlayer

func _ready():
	_play_animation()

func press_button():
	if Engine.is_editor_hint() or is_pressed: return
	is_pressed = true
	button_pressed.emit()
	

func _on_body_entered(body):
	if Engine.is_editor_hint(): return
	if body is Player:
		press_button()

func _play_animation():
	if not animation_player: return
	if is_pressed:
		animation_player.play("press")
	else:
		animation_player.play_backwards("press")
	
