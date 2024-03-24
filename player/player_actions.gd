class_name PlayerActions
extends Node

signal stun_triggered

@export var player: CharacterBody2D

var is_stunned = false:
	set(value):
		if not is_stunned and value:
			stun_triggered.emit()
		is_stunned = value

func get_movement_direction() -> float:
	if is_stunned: return 0.0
	return Input.get_axis("move_left", "move_right")

func is_charging() -> bool:
	if is_stunned: return false
	return Input.is_action_pressed("charge")

#region Jump

signal jump_triggered

@export var max_jump_remember_time = .1
@export var max_coyote_time = .15

var jump_pressed_remember_time = 0.0
var coyote_time = 0.0

func _handle_jump_input(delta: float):
	if jump_pressed_remember_time > 0:
		jump_pressed_remember_time -= delta
	if coyote_time > 0:
		coyote_time -= delta
	
	if Input.is_action_just_pressed("jump"):
		jump_pressed_remember_time = max_jump_remember_time
	if player.is_on_floor():
		coyote_time = max_coyote_time
	
	if coyote_time > 0 and jump_pressed_remember_time > 0 and not is_stunned:
		jump_triggered.emit()
		coyote_time = 0.0
		jump_pressed_remember_time = 0.0
		
#endregion


func _process(delta):
	_handle_jump_input(delta)
