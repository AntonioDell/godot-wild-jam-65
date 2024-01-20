extends CharacterBody2D
class_name Player

signal player_died()

@export_category("Dependendent nodes")
@export var charge_audio: AudioStreamPlayer
@export var rocket: RocketWithDecimals 
@export var player_triggered_jump: Jump
@export var jump_input: JumpInput
@export var drone_triggered_jump: Jump

@export_category("Movement")
@export var walking_speed = 150.0
@export var max_gravity = 750.0
@export var walking_slowdown = 0.05

@export_category("Audio")
@export var charge_audio_playback_position = 6.8
@export var charge_audio_playback_length = 12.0 - 6.8


enum HorizontalState {
	IDLE_RIGHT,
	IDLE_LEFT,
	RIGHT,
	LEFT
}
var horizontal_state = HorizontalState.IDLE_RIGHT
var gravity_acceleration = 0.0
var charge_animation_playback_speed = 1.0 :
	get:
		var charge_animation_length = animation_player.get_animation("charge_right").length
		return charge_animation_length / (rocket.max_charge_time_seconds - rocket.max_charge_delay)
var is_stunned = false
var rocket_velocity := Vector2.ZERO:
	set(value):
		if sign(rocket_velocity.y) == -1 and sign(value.y) >= 0: 
			if horizontal_state == HorizontalState.LEFT or horizontal_state == HorizontalState.IDLE_LEFT:
				animation_player.play("fly_highest_point_reached_left")
			else:
				animation_player.play("fly_highest_point_reached_right")
		rocket_velocity = value
var is_death = false:
	set(value):
		is_death = value
		charge_audio.stop()

@onready var robot_sprites = %RobotSprites
@onready var animation_player = %AnimationPlayer
@onready var camera: Camera2D = %Camera


func die():
	if is_death: return 
	is_death = true
	animation_player.play("death")
	await animation_player.animation_finished
	player_died.emit()

func _ready():
	rocket.charging_started.connect(_on_rocket_charging_started)
	rocket.max_charge_reached.connect(_on_rocket_max_charge_reached)
	rocket.rocket_started.connect(_on_rocket_started)
	rocket.rocket_stopped.connect(_on_rocket_stopped)
	rocket.overload_started.connect(_on_rocket_overload_started)
	rocket.overload_ended.connect(_on_rocket_overload_ended)
	
	jump_input.jump_triggered.connect(func(): 
		player_triggered_jump.start())
	player_triggered_jump.jump_started.connect(_jump_started)
	drone_triggered_jump.jump_started.connect(_jump_started)

func _physics_process(delta):
	if is_death: return
	move_and_slide()

func _process(delta: float):
	if is_death: return 
	
	var horizontal_velocity = _get_horizontal_velocity(delta)
	var vertical_velocity = _get_vertical_velocity(delta)
	velocity = horizontal_velocity + vertical_velocity

func _get_horizontal_velocity(delta: float):
	if is_stunned: return Vector2.ZERO
	
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	if rocket.is_charging: 
		var slowdown = walking_slowdown if is_on_floor() else 1.0
		return Vector2.RIGHT * horizontal_direction * walking_speed * slowdown
	
	if not rocket.is_rocket_active:
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
	jump_input.handle_jump_input(delta, _is_on_floor)
	
	var gravity_velocity =  _get_gravity_vector(delta)
	
	# FIXME: This will stop working as soon as multiple obstacles with jumps exist
	# The higher priority obstacle may always block the lower prio ones 
	# -> maybe only apply the one with the lowest y value?
	var drone_jump_velocity = drone_triggered_jump.get_vertical_velocity(delta)
	if drone_jump_velocity != Vector2.ZERO:
		is_stunned = false
		return drone_jump_velocity + gravity_velocity
	
	if is_stunned:
		return gravity_velocity
	
	rocket_velocity = rocket.get_vertical_velocity(delta, _is_on_floor)
	if rocket_velocity != Vector2.ZERO:
		rocket_velocity += gravity_velocity
		return rocket_velocity
	
	var player_jump_velocity = player_triggered_jump.get_vertical_velocity(delta)
	return player_jump_velocity + gravity_velocity

func _get_gravity_vector(delta: float):
	var strength = 0.0
	if not is_on_floor():
		# Airborne
		gravity_acceleration += delta
		var v = clampf(gravity_acceleration, 0.0, 1.0)
		strength = lerpf(0.0, max_gravity, ease(v, .4))
	else:
		gravity_acceleration = 0.0
	return Vector2.DOWN * strength

func _on_rocket_charging_started():
	if is_death: return 
	
	if horizontal_state == HorizontalState.LEFT or horizontal_state == HorizontalState.IDLE_LEFT:
		animation_player.play("charge_left", -1, charge_animation_playback_speed)
	else:
		animation_player.play("charge_right", -1, charge_animation_playback_speed)
	
	charge_audio.pitch_scale = charge_audio_playback_length / rocket.max_charge_time_seconds
	charge_audio.play(charge_audio_playback_position)

func _on_rocket_max_charge_reached():
	if is_death: return 
	
	if horizontal_state == HorizontalState.LEFT or horizontal_state == HorizontalState.IDLE_LEFT:
		animation_player.play("max_charge_left")
	else:
		animation_player.play("max_charge_right")

func _on_rocket_started(charge_level: int):
	if is_death: return 
	
	gravity_acceleration = 0.0
	
	if horizontal_state == HorizontalState.LEFT or horizontal_state == HorizontalState.IDLE_LEFT:
		animation_player.play("fly_left")
	else:
		animation_player.play("fly_right")
	
	charge_audio.stop()
	(get_node("Blastoff%sAudio" % charge_level) as AudioStreamPlayer).play()

func _on_rocket_stopped():
	if is_death: return 

func _explode():
	if is_death: return 
	
	if horizontal_state == HorizontalState.LEFT or horizontal_state == HorizontalState.IDLE_LEFT:
		animation_player.play("overload_left")
		animation_player.queue("idle_left")
	else:
		animation_player.play("overload_right")
		animation_player.queue("idle_right")
	
	is_stunned = true
	await animation_player.animation_finished
	is_stunned = false
	

func _on_rocket_overload_started():
	if is_death: return 
	
	charge_audio.stop()
	
	_explode()

func _on_rocket_overload_ended():
	if is_death: return 
	# TODO: Play shakeoff animation
	
func _jump_started():
	if is_death: return 
	
	gravity_acceleration = 0.0

# Bird interactions
func _on_bird_stun_collision_area_body_entered(body):
	if is_death: return 
	
	(body as Bird).get_sucked_in(Vector2.ZERO)
	_explode()
