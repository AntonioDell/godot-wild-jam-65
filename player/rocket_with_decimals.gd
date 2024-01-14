extends Node
class_name RocketWithDecimals


signal charging_started()
signal rocket_started()
signal rocket_stopped()


@export var max_vertical_speed = 500.0
@export var max_vertical_acceleration_duration = 3.0
@export var max_charge_time_seconds = 1


var is_charging = false
var is_rocket_active = false:
	set(value):
		if value:
			print("Done")
			rocket_started.emit()
		else:
			rocket_stopped.emit()
		is_rocket_active = value
var charge_time = 0.0
var min_charge = .2
var charge = 0.0
var time_since_liftoff = 0.0
var jump_duration = 0.0


func get_vertical_velocity(delta: float) -> Vector2:
	if is_rocket_active:
		time_since_liftoff += delta
		var strength = max_vertical_speed * (1 - inverse_lerp(0.0, jump_duration, time_since_liftoff))
		return Vector2.UP * strength
	else:
		_handle_rocket_charge_input(delta)
		return Vector2.ZERO


func _handle_rocket_charge_input(delta: float):
	var value = Input.is_action_pressed("charge")
	if value and not is_charging:
		_begin_charging_rocket()
	elif not value and is_charging:
		# TODO: Add overload state 
		_start_rocket()
	elif value and is_charging:
		charge_time += delta

func _begin_charging_rocket():
	charge_time = 0.0
	is_charging = true
	charging_started.emit()

func _start_rocket():
	charge = clampf(inverse_lerp(0.0, max_charge_time_seconds, charge_time), min_charge, 1.0)
	jump_duration = smoothstep(0.0, max_vertical_acceleration_duration, charge * max_vertical_acceleration_duration)
	
	time_since_liftoff = 0.0
	charge_time = 0.0
	is_charging = false
	
	is_rocket_active = true
	await get_tree().create_timer(jump_duration).timeout
	is_rocket_active = false
	rocket_stopped

