extends Node
class_name Jump

signal jump_started()
signal jump_ended()

@export var max_jump_duration = .2
@export var max_jump_speed = 500.0

var is_jumping = false
var time_since_jump = 0.0


func start():
	jump_started.emit()
	time_since_jump = 0.0
	is_jumping = true

func get_vertical_velocity(delta: float) -> Vector2:
	var ret = Vector2.ZERO
	if is_jumping:
		var strength = max_jump_speed *  (1 - ease(inverse_lerp(0.0, max_jump_duration, time_since_jump), .4))
		ret = Vector2.UP * strength
	
	time_since_jump += delta
	if time_since_jump >= max_jump_duration:
		_end_jump()
	return ret

func _end_jump():
	jump_ended.emit()
	is_jumping = false
