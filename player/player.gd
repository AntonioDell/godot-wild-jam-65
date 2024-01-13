extends CharacterBody2D

const GRAVITY = 100.0

@export var max_vertical_speed = 500.0
@export var max_vertical_acceleration_duration = 3.0
@export var max_charge_time_seconds = 1

var is_charging = false
var is_jumping = false
var charge_time = 0.0
var charge_animation_playback_speed = 1.0

@onready var rocket_sprites = %RocketSprites
@onready var robot_sprites = %RobotSprites
@onready var animation_player = %AnimationPlayer

func _ready():
	var charge_animation_length = animation_player.get_animation("charge").length
	charge_animation_playback_speed = charge_animation_length / max_charge_time_seconds

func _process(delta: float):
	_handle_player_input(delta)

func _physics_process(delta):
	move_and_slide()

func _handle_player_input(delta: float):
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	if horizontal_direction < 0:
		rocket_sprites.flip_h = true
		robot_sprites.flip_h = true
	elif horizontal_direction > 0: 
		rocket_sprites.flip_h = false
		robot_sprites.flip_h = false
		
	velocity = Vector2.RIGHT * horizontal_direction * 100.0 + _get_gravity_vector(delta)
	
	if is_jumping: 
		velocity = velocity + _get_jump_vector(delta)
		return
	
	var value = Input.is_action_pressed("charge")
	if value and not is_charging:
		_start_charging()
	elif not value and is_charging:
		# TODO: Add overload state 
		_start_jump()
	elif value and is_charging:
		charge_time += delta

var max_gravity = 1000.0
var gravity_acceleration = 0.0
func _get_gravity_vector(delta: float):
	var strength = 0.0
	if is_jumping:
		# Jumping
		gravity_acceleration = 0.0
	elif not is_on_floor():
		# Falling
		gravity_acceleration += delta
		var v = clampf(gravity_acceleration, 0.0, 1.0)
		strength = lerpf(0.0, max_gravity, ease(v, .4))
	return Vector2.DOWN * strength

func _start_charging():
	charge_time = 0.0
	is_charging = true
	animation_player.play("charge", -1, charge_animation_playback_speed)

var min_charge = .2
var charge = 0.0
var time_since_liftoff = 0.0
var jump_duration = 0.0
var initial_acceleration = 0.0
func _start_jump():
	animation_player.stop()
	charge = clampf(inverse_lerp(0.0, max_charge_time_seconds, charge_time), min_charge, 1.0)
	initial_acceleration = max_vertical_speed * charge
	jump_duration = smoothstep(0.0, max_vertical_acceleration_duration, charge * max_vertical_acceleration_duration)
	
	time_since_liftoff = 0.0
	charge_time = 0.0
	is_charging = false
	
	is_jumping = true
	await get_tree().create_timer(jump_duration).timeout
	is_jumping = false

func _get_jump_vector(delta):
	time_since_liftoff += delta
	var v = 1 - inverse_lerp(0.0, jump_duration, time_since_liftoff)
	var strength = max_vertical_speed * v
	print(strength)
	return Vector2.UP * strength
	
