extends State


@export_group("States", "state_")
@export var state_falling: State

@export var max_vertical_speed = 400.0
@export var max_vertical_acceleration_duration = 1
@export var airborne_speed: float = 150.0

#region Injectables

var player: CharacterBody2D
var player_actions: PlayerActions
var animation_player: AnimationPlayer
var rocket_state_machine: RocketStateMachine

#endregion

var max_rocket_duration = 0.0
var rocket_duration = 0.0

func enter():
	var charge = rocket_state_machine.last_charge
	max_rocket_duration = charge * max_vertical_acceleration_duration
	rocket_duration = max_rocket_duration
	
	_animate_thrust()

func process_physics(delta: float) -> State:
	var v_y = max_vertical_speed * inverse_lerp(0.0, max_rocket_duration, rocket_duration)
#region Ariborne walking 
	var v_x = player_actions.get_movement_direction() * airborne_speed
	player.velocity = Vector2(v_x, -v_y)
#endregion
	
	rocket_duration -= delta
	if rocket_duration <= 0:
		return state_falling
		
	return null

func exit():
	_animate_higest_point()

func _animate_thrust():
	var current_animation = animation_player.current_animation
	if current_animation.ends_with("left"):
		animation_player.play("fly_left")
	else:
		animation_player.play("fly_right")

func _animate_higest_point():
	var current_animation = animation_player.current_animation
	if current_animation == "fly_left":
		animation_player.play("fly_highest_point_reached_left")
	elif current_animation == "fly_right":
		animation_player.play("fly_highest_point_reached_right")
