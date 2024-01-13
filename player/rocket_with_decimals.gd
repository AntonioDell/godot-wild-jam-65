extends Node
class_name RocketWithDecimals


signal charging_started()
signal rocket_started()


@export var max_vertical_speed = 500.0
@export var max_vertical_acceleration_duration = 3.0
@export var max_charge_time_seconds = 1


var is_charging = false
var is_rocket_active = false
var charge_time = 0.0
var is_on_floor = true
var min_charge = .2
var charge = 0.0
var time_since_liftoff = 0.0
var jump_duration = 0.0


func get_vertical_velocity(delta: float, _is_on_floor: bool) -> Vector2:
	is_on_floor = _is_on_floor
	
	var ret = _get_vertical_vector(delta)
	_handle_rocket_charge_input(delta)
	return ret

# TODO: Extract rocket logic to make it hot swappable
func _handle_rocket_charge_input(delta: float):
	if is_rocket_active: 
		# Charging not possible if already active
		return
	
	var value = Input.is_action_pressed("charge")
	if value and not is_charging:
		_begin_charging_rocket()
	elif not value and is_charging:
		# TODO: Add overload state 
		_start_rocket()
	elif value and is_charging:
		_charge_rocket(delta)

func _get_vertical_vector(delta):
	if is_rocket_active:
		time_since_liftoff += delta
		var v = 1 - inverse_lerp(0.0, jump_duration, time_since_liftoff)
		var strength = max_vertical_speed * v
		return Vector2.UP * strength
	else:
		return _get_gravity_vector(delta)

func _begin_charging_rocket():
	charge_time = 0.0
	is_charging = true
	charging_started.emit()

func _charge_rocket(delta):
	charge_time += delta

var max_gravity = 1000.0
var gravity_acceleration = 0.0
func _get_gravity_vector(delta: float):
	var strength = 0.0
	if is_rocket_active:
		# Jumping
		gravity_acceleration = 0.0
	elif not is_on_floor:
		# Falling
		gravity_acceleration += delta
		var v = clampf(gravity_acceleration, 0.0, 1.0)
		strength = lerpf(0.0, max_gravity, ease(v, .4))
	return Vector2.DOWN * strength


func _start_rocket():
	rocket_started.emit()
	charge = clampf(inverse_lerp(0.0, max_charge_time_seconds, charge_time), min_charge, 1.0)
	jump_duration = smoothstep(0.0, max_vertical_acceleration_duration, charge * max_vertical_acceleration_duration)
	
	time_since_liftoff = 0.0
	charge_time = 0.0
	is_charging = false
	
	is_rocket_active = true
	await get_tree().create_timer(jump_duration).timeout
	is_rocket_active = false

