extends CharacterBody2D

const GRAVITY = 100.0

@export var max_vertical_speed = 250.0
@export var max_vertical_acceleration_duration = 3.0
@export var max_charge_time_seconds = 3.0

var is_charging = false
var is_jumping = false
var charge_time = 0.0

func _process(delta: float):
	_handle_player_input(delta)
	

func _physics_process(delta):
	move_and_slide()

func _handle_player_input(delta: float):
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	velocity = Vector2.RIGHT * horizontal_direction * 100.0 + Vector2.DOWN * GRAVITY
	
	if is_jumping: 
		# TODO: Use easing for acceleration
		velocity = velocity + (Vector2.UP * max_vertical_speed)
		return
	
	var value = Input.is_action_pressed("charge")
	if value and not is_charging:
		_start_charging()
	elif not value and is_charging:
		# TODO: Add overload state 
		_jump()
	elif value and is_charging:
		charge_time += delta

func _start_charging():
	charge_time = 0.0
	is_charging = true

func _jump():
	var charge = clampf(lerpf(0.0, max_charge_time_seconds, charge_time), 0.0, 1.0)
	charge_time = 0.0
	is_charging = false
	
	is_jumping = true
	await get_tree().create_timer(smoothstep(0.0,max_vertical_acceleration_duration,  charge * max_vertical_acceleration_duration)).timeout
	is_jumping = false
