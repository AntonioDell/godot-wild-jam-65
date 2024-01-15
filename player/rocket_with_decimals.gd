extends Node
class_name RocketWithDecimals


signal charging_started()
signal max_charge_reached()
signal rocket_started()
signal rocket_stopped()
signal overload_started()
signal overload_ended()


@export var max_vertical_speed = 1000.0
@export var max_vertical_acceleration_duration = 1
@export var max_charge_time_seconds = 2.2 # = charge_right + max_charge_delay
@export var max_charge_delay = .4 
@export var max_overload_time = 1.0
@export var min_charge = 0.0


var is_charging = false
var is_rocket_active = false:
	set(value):
		if value:
			rocket_started.emit()
		else:
			rocket_stopped.emit()
		is_rocket_active = value
var charge_time = 0.0
var charge = 0.0
var max_rocket_duration = 0.0
var rocket_duration = 0.0
var left_floor = false
var is_overloaded = false
var overload_timer = 0.0


func get_vertical_velocity(delta: float, is_on_floor: bool) -> Vector2:
	var ret = Vector2.ZERO
	
	if is_rocket_active and rocket_duration > 0:
		if not left_floor and not is_on_floor:
			left_floor = true
		elif left_floor and is_on_floor:
			left_floor = false
			_end_rocket()
		else:
			var strength = max_vertical_speed * inverse_lerp(0.0, max_rocket_duration, rocket_duration)
			rocket_duration -= delta
			ret = Vector2.UP * strength
	elif is_rocket_active:
		_end_rocket()
	else:
		_handle_rocket_charge_input(delta)
	
	return ret

func _handle_rocket_charge_input(delta: float):
	if is_overloaded: 
		if overload_timer > 0:
			overload_timer -= delta
		else:
			_end_overload()
		return
	
	var value = Input.is_action_pressed("charge")
	if value and not is_charging:
		_begin_charging_rocket()
	elif not value and is_charging:
		# TODO: Add overload state
		_start_rocket()
	elif value and is_charging:
		if charge_time > max_charge_time_seconds:
			_start_overload()
		else:
			if charge_time > max_charge_time_seconds - max_charge_delay:
				max_charge_reached.emit()
			charge_time += delta

func _begin_charging_rocket():
	charge_time = 0.0
	is_charging = true
	charging_started.emit()

func _start_rocket():
	charge = clampf(inverse_lerp(0.0, max_charge_time_seconds - max_charge_delay, charge_time), min_charge, 1.0)
	max_rocket_duration = charge * max_vertical_acceleration_duration
	rocket_duration = max_rocket_duration
	charge_time = 0.0
	is_charging = false
	is_rocket_active = true

func _end_rocket():
	is_rocket_active = false
	left_floor = false

func _start_overload():
	overload_started.emit()
	charge_time = 0.0
	is_charging = false
	is_rocket_active = false
	left_floor = false
	is_overloaded = true
	# Start overload timer
	overload_timer = max_overload_time

func _end_overload():
	overload_ended.emit()
	is_overloaded = false
