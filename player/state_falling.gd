extends State


@export_group("States", "state_")
@export var state_idle: State
@export var state_drone_jump: State
@export var state_walking: State

@export_group("Gravity", "gravity_")
@export var gravity_max_velocity: float
@export var gravity_time_to_max_velocity: float
@export var gravity_velocity_curve: Curve

@export_group("Airborne movement")
@export var airborne_speed: float = 150.0

#region Injectables

var player: CharacterBody2D
var player_actions: PlayerActions

#endregion

var drone_jump_triggered = false
var time_since_falling_started = 0

func enter():
	time_since_falling_started = 0
	drone_jump_triggered = false
	
	if not "trigger_drone_jump" in player:
		push_error("Player doesn't have `trigger_drone_jump` signal!")
	else:
		player.trigger_drone_jump.connect(_trigger_drone_jump)

func process_physics(delta: float) -> State:
	if drone_jump_triggered:
		return state_drone_jump
	
	# TODO: Add input buffer to allow for walking input before landing
	if player.is_on_floor():
		if player_actions.get_movement_direction() != 0:
			return state_walking
		else:
			return state_idle
	
	# TODO: Play falling animation
	
	var t = clampf(inverse_lerp(0.0, gravity_time_to_max_velocity, time_since_falling_started), 0.0, 1.0)
	var v_y = gravity_max_velocity * gravity_velocity_curve.sample(t)
	
#region Ariborne walking 
	var v_x = player_actions.get_movement_direction() * airborne_speed
	player.velocity = Vector2(v_x, v_y)
	player.move_and_slide()
#endregion
	
	# TODO: Add edge case for infinite fall -> player should die probably
	
	time_since_falling_started += delta
	return null

func exit():
	player.trigger_drone_jump.disconnect(_trigger_drone_jump)

func _trigger_drone_jump():
	drone_jump_triggered = true
