extends Node
class_name Jump

signal jump_started()
signal jump_ended()

@export var max_jump_remember_time = .1
@export var max_coyote_time = .15
@export var max_jump_duration = .2
@export var max_jump_speed = 750.0

var jump_pressed_remember_time = 0.0
var coyote_time = 0.0
var jump_duration = 0.0
var is_jumping = false:
	set(value):
		if value:
			jump_started.emit()
		else:
			jump_ended.emit()
		is_jumping = value
var left_floor = false

func get_vertical_velocity(delta: float, is_on_floor: bool) -> Vector2:
	var ret = Vector2.ZERO
	if is_jumping and jump_duration > 0.0:
		# Execute jump
		if not left_floor and not is_on_floor:
			left_floor = true
		elif left_floor and is_on_floor:
			left_floor = false
			_end_jump()
		else:
			var strength = max_jump_speed * inverse_lerp(0.0, max_jump_duration, jump_duration)
			jump_duration -= delta
			ret= Vector2.UP * strength
	elif is_jumping:
		_end_jump()
		
	if jump_pressed_remember_time > 0:
		jump_pressed_remember_time -= delta
	if coyote_time > 0:
		coyote_time -= delta
	
	# Check for jumping
	if Input.is_action_just_pressed("jump"):
		jump_pressed_remember_time = max_jump_remember_time
	if is_on_floor:
		coyote_time = max_coyote_time
	
	if not is_jumping and coyote_time > 0 and jump_pressed_remember_time > 0:
		_start_jump()
	
	return ret
	

func _start_jump():
	jump_duration = max_jump_duration
	jump_pressed_remember_time = 0.0
	is_jumping = true

func _end_jump():
	jump_duration = 0
	is_jumping = false
	left_floor = false
