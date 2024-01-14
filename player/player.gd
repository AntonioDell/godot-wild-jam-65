extends CharacterBody2D

@export var walking_speed = 250.0
@export var rocket_with_decimals: RocketWithDecimals


var charge_animation_playback_speed = 1.0

@onready var rocket_sprites = %RocketSprites
@onready var robot_sprites = %RobotSprites
@onready var animation_player = %AnimationPlayer


func _ready():
	var charge_animation_length = animation_player.get_animation("charge").length
	charge_animation_playback_speed = charge_animation_length / rocket_with_decimals.max_charge_time_seconds
	rocket_with_decimals.charging_started.connect(_on_rocket_charging_started)
	rocket_with_decimals.rocket_started.connect(_on_rocket_started)
	rocket_with_decimals.rocket_started.connect(_on_rocket_stopped)

func _physics_process(delta):
	move_and_slide()

func _process(delta: float):
	var horizontal_velocity = _get_horizontal_velocity(delta)
	var vertical_velocity = _get_vertical_velocity(delta)
	if vertical_velocity != Vector2.ZERO:
		print(vertical_velocity)
	velocity = horizontal_velocity + vertical_velocity

func _get_horizontal_velocity(delta: float):
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	if horizontal_direction < 0:
		rocket_sprites.flip_h = true
		robot_sprites.flip_h = true
	elif horizontal_direction > 0: 
		rocket_sprites.flip_h = false
		robot_sprites.flip_h = false
	
	# TODO: Add acceleration and damping
	# TODO: Add airborne movement
	return Vector2.RIGHT * horizontal_direction * walking_speed

func _get_vertical_velocity(delta: float) -> Vector2:
	# TODO: Add jump
	var vertical_jump_velocity = _handle_jump(delta)
	var vertical_rocket_velocity = rocket_with_decimals.get_vertical_velocity(delta) 
	if vertical_rocket_velocity == Vector2.ZERO:
		return vertical_jump_velocity + _get_gravity_vector(delta)
	else:
		return vertical_rocket_velocity

var max_jump_remember_time = .1
var jump_pressed_remember_time = 0.0

var max_coyote_time = .15
var coyote_time = 0.0

var max_jump_duration = 1.0
var jump_duration = 0.0

var is_jumping = false
var max_jump_speed = 500.0
var left_floor = false
func _handle_jump(delta: float) -> Vector2:
	# Execute jump
	var ret = Vector2.ZERO
	if is_jumping and jump_duration > 0.0:
		if not left_floor and not is_on_floor():
			left_floor = true
		elif left_floor and is_on_floor():
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
	if is_on_floor():
		coyote_time = max_coyote_time
	
	if coyote_time > 0 and jump_pressed_remember_time > 0:
		print(coyote_time)
		_start_jump()
	
	return ret
	

func _start_jump():
	jump_duration = max_jump_duration
	jump_pressed_remember_time = 0.0
	is_jumping = true

func _end_jump():
	jump_duration = 0
	is_jumping = false

func _on_rocket_charging_started():
	animation_player.play("charge", -1, charge_animation_playback_speed)

var is_rocket_active = false
func _on_rocket_started():
	animation_player.stop()
	is_rocket_active = true

func _on_rocket_stopped():
	is_rocket_active = false


# Gravity
var max_gravity = 750.0
var gravity_acceleration = 0.0
func _get_gravity_vector(delta: float):
	var strength = 0.0
	if is_rocket_active:
		gravity_acceleration = 0.0
	elif not is_on_floor():
		# Falling
		gravity_acceleration += delta
		var v = clampf(gravity_acceleration, 0.0, 1.0)
		strength = lerpf(0.0, max_gravity, ease(v, .4))
	else:
		gravity_acceleration = 0.0
	return Vector2.DOWN * strength
