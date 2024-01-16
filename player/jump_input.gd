extends Node
class_name JumpInput

signal jump_triggered

@export var max_jump_remember_time = .1
@export var max_coyote_time = .15

var jump_pressed_remember_time = 0.0
var coyote_time = 0.0

func handle_jump_input(delta: float, is_on_floor: bool):
	if jump_pressed_remember_time > 0:
		jump_pressed_remember_time -= delta
	if coyote_time > 0:
		coyote_time -= delta
	
	if Input.is_action_just_pressed("jump"):
		jump_pressed_remember_time = max_jump_remember_time
	if is_on_floor:
		coyote_time = max_coyote_time
	
	if coyote_time > 0 and jump_pressed_remember_time > 0:
		jump_triggered.emit()
		coyote_time = 0.0
		jump_pressed_remember_time = 0.0
		
