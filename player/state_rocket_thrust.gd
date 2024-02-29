extends State


@export_group("Tilt", "tilt_")
@export_range(0, .5 * PI) var tilt_max = PI * .25
@export var tilt_time_to_max: float = 1.0

@export_group("States", "state_")
@export var state_falling: State

#region Injectables

var player: CharacterBody2D
var player_actions: PlayerActions
var rocket_state_machine: RocketStateMachine

#endregion

var tilt_speed = tilt_max / tilt_time_to_max
var tilt = 0.0

func enter():
	pass

func process_physics(delta: float) -> State:
	
	var tilt_direction = player_actions.get_movement_direction()
	tilt = clampf(tilt + (tilt_direction * tilt_speed * delta), -tilt_max , tilt_max)
	
	return null
