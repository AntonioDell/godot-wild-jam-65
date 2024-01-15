extends CharacterBody2D
class_name Player

@export_category("Movement")
@export var rocket: RocketWithDecimals
@export var jump: Jump
@export var walking_speed = 250.0
@export var max_gravity = 750.0
@export var walking_slowdown = 0.05

@export_category("Audio")
@export var charge_audio_playback_position = 6.8
@export var charge_audio_playback_length = 12.0 - 6.8

@onready var robot_sprites = %RobotSprites
@onready var animation_player = %AnimationPlayer
@onready var charge_audio: AudioStreamPlayer = %ChargeAudio

enum HorizontalState {
	IDLE_RIGHT,
	IDLE_LEFT,
	RIGHT,
	LEFT
}
var horizontal_state = HorizontalState.IDLE_RIGHT
var gravity_acceleration = 0.0
var charge_animation_playback_speed = 1.0
var is_jumping = false
var is_stunned = false
var is_charging = false
var rocket_velocity := Vector2.ZERO:
	set(value):
		if sign(rocket_velocity.y) == -1 and sign(value.y) >= 0: 
			if horizontal_state == HorizontalState.LEFT or horizontal_state == HorizontalState.IDLE_LEFT:
				animation_player.play("fly_highest_point_reached_left")
			else:
				animation_player.play("fly_highest_point_reached_right")
		rocket_velocity = value

func _ready():
	# We assume charge_right and charge_left have the same length!
	var charge_animation_length = animation_player.get_animation("charge_right").length
	charge_animation_playback_speed = charge_animation_length / (rocket.max_charge_time_seconds - rocket.max_charge_delay)
	
	charge_audio.pitch_scale = charge_audio_playback_length / rocket.max_charge_time_seconds
	
	rocket.charging_started.connect(_on_rocket_charging_started)
	rocket.max_charge_reached.connect(_on_rocket_max_charge_reached)
	rocket.rocket_started.connect(_on_rocket_started)
	rocket.rocket_started.connect(_on_rocket_stopped)
	rocket.overload_started.connect(_on_rocket_overload_started)
	rocket.overload_ended.connect(_on_rocket_overload_ended)
	
	jump.jump_started.connect(_on_jump_started)
	jump.jump_ended.connect(_on_jump_ended)

func _physics_process(delta):
	move_and_slide()

func _process(delta: float):
	var horizontal_velocity = _get_horizontal_velocity(delta)
	var vertical_velocity = _get_vertical_velocity(delta)
	velocity = horizontal_velocity + vertical_velocity

func _get_horizontal_velocity(delta: float):
	if is_stunned: return Vector2.ZERO
	
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	if is_charging: 
		var slowdown = walking_slowdown if is_on_floor() else 1.0
		return Vector2.RIGHT * horizontal_direction * walking_speed * slowdown
	
	if is_on_floor() or is_jumping:
		if horizontal_direction < 0 and horizontal_state != HorizontalState.LEFT:
			if horizontal_state != HorizontalState.IDLE_LEFT:
				# Robot is facing right -> Turn left before walking 
				animation_player.play("turn")
			horizontal_state = HorizontalState.LEFT
			animation_player.queue("walk_left")
		elif horizontal_direction > 0 and horizontal_state != HorizontalState.RIGHT:
			if horizontal_state != HorizontalState.IDLE_RIGHT: 
				animation_player.play("turn")
			horizontal_state = HorizontalState.RIGHT
			animation_player.queue("walk_right")
		elif horizontal_direction == 0:
			if horizontal_state == HorizontalState.LEFT:
				animation_player.play("idle_left")
				horizontal_state = HorizontalState.IDLE_LEFT
			elif horizontal_state == HorizontalState.RIGHT:
				animation_player.play("idle_right")
				horizontal_state = HorizontalState.IDLE_RIGHT
	
	# TODO: Add acceleration and damping (maybe)
	# TODO: Add airborne movement (maybe)
	return Vector2.RIGHT * horizontal_direction * walking_speed

func _get_vertical_velocity(delta: float) -> Vector2:
	var _is_on_floor = is_on_floor() 
	var vertical_jump_velocity = jump.get_vertical_velocity(delta, _is_on_floor)
	var vertical_rocket_velocity = rocket.get_vertical_velocity(delta, _is_on_floor)
	var vertical_gravity_velocity =  _get_gravity_vector(delta)
	
	if is_stunned:
		return vertical_gravity_velocity
	elif vertical_rocket_velocity == Vector2.ZERO:
		return vertical_jump_velocity + vertical_gravity_velocity
	else:
		rocket_velocity = vertical_rocket_velocity + vertical_gravity_velocity
		return rocket_velocity

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
	is_charging = true
	if horizontal_state == HorizontalState.LEFT or horizontal_state == HorizontalState.IDLE_LEFT:
		animation_player.play("charge_left", -1, charge_animation_playback_speed)
	else:
		animation_player.play("charge_right", -1, charge_animation_playback_speed)
	
	charge_audio.play(charge_audio_playback_position)
	

func _on_rocket_max_charge_reached():
	if horizontal_state == HorizontalState.LEFT or horizontal_state == HorizontalState.IDLE_LEFT:
		animation_player.play("max_charge_left")
	else:
		animation_player.play("max_charge_right")

func _on_rocket_started():
	is_charging = false
	gravity_acceleration = 0.0
	
	if horizontal_state == HorizontalState.LEFT or horizontal_state == HorizontalState.IDLE_LEFT:
		animation_player.play("fly_left")
	else:
		animation_player.play("fly_right")
	
	# TODO: Play blastoff audio
	charge_audio.stop()

func _on_rocket_stopped():
	pass

func _on_rocket_overload_started():
	is_charging = false
	if horizontal_state == HorizontalState.LEFT or horizontal_state == HorizontalState.IDLE_LEFT:
		animation_player.play("overload_left")
		animation_player.queue("idle_left")
	else:
		animation_player.play("overload_right")
		animation_player.queue("idle_right")
	
	# TODO: Play overload audio
	charge_audio.stop()
	
	is_stunned = true
	await animation_player.animation_finished
	is_stunned = false

func _on_rocket_overload_ended():
	# TODO: Play shakeoff animation
	pass
	
func _on_jump_started(): 
	is_jumping = true
	gravity_acceleration = 0.0
	
func _on_jump_ended():
	is_jumping = false
