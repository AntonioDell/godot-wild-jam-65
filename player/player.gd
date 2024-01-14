extends CharacterBody2D

@export var walking_speed = 250.0
@export var rocket_with_decimals: RocketWithDecimals
@export var jump: Jump

@onready var rocket_sprites = %RocketSprites
@onready var robot_sprites = %RobotSprites
@onready var animation_player = %AnimationPlayer

var charge_animation_playback_speed = 1.0
var is_rocket_active = false
var is_jumping = false
var max_gravity = 750.0
var gravity_acceleration = 0.0


func _ready():
	var charge_animation_length = animation_player.get_animation("charge").length
	charge_animation_playback_speed = charge_animation_length / rocket_with_decimals.max_charge_time_seconds
	rocket_with_decimals.charging_started.connect(_on_rocket_charging_started)
	rocket_with_decimals.rocket_started.connect(_on_rocket_started)
	rocket_with_decimals.rocket_started.connect(_on_rocket_stopped)
	jump.jump_started.connect(_on_jump_started)
	jump.jump_ended.connect(_on_jump_ended)

func _physics_process(delta):
	move_and_slide()

func _process(delta: float):
	var horizontal_velocity = _get_horizontal_velocity(delta)
	var vertical_velocity = _get_vertical_velocity(delta)
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
	var _is_on_floor = is_on_floor() 
	var vertical_jump_velocity = jump.get_vertical_velocity(delta, _is_on_floor)
	var vertical_rocket_velocity = rocket_with_decimals.get_vertical_velocity(delta, _is_on_floor)
	var vertical_gravity_velocity =  _get_gravity_vector(delta)
	
	if vertical_rocket_velocity == Vector2.ZERO:
		return vertical_jump_velocity + vertical_gravity_velocity
	else:
		return vertical_rocket_velocity + vertical_gravity_velocity

func _get_gravity_vector(delta: float):
	var strength = 0.0
	if not is_on_floor():
		# Falling
		gravity_acceleration += delta
		var v = clampf(gravity_acceleration, 0.0, 1.0)
		strength = lerpf(0.0, max_gravity, ease(v, .4))
	else:
		gravity_acceleration = 0.0
	return Vector2.DOWN * strength


func _on_rocket_charging_started():
	animation_player.play("charge", -1, charge_animation_playback_speed)

func _on_rocket_started():
	animation_player.stop()
	is_rocket_active = true
	gravity_acceleration = 0.0

func _on_rocket_stopped():
	is_rocket_active = false
	
func _on_jump_started(): 
	is_jumping = true
	gravity_acceleration = 0.0
	
func _on_jump_ended():
	is_jumping = false
