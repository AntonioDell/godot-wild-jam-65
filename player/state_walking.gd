extends State

@export var state_falling: State
@export var state_idle: State

@export var speed := 150.0
@export var charge_slowdown := 0.05

#region Injectables

var player: CharacterBody2D
var player_actions: PlayerActions
var rocket_state_machine: RocketStateMachine

#endregion

func process_physics(delta: float) -> State:
	if not player.is_on_floor():
		return state_falling
	
	var direction = player_actions.get_movement_direction()
	if direction == 0 and player.get_last_slide_collision() and player.get_last_slide_collision().get_travel().length_squared() != 0:
		return state_idle
	
	var slowdown = charge_slowdown if rocket_state_machine.is_charging else 1.0
	
	# TODO: Play walking animation
	# TODO: Add acceleration and deceleration
	
	player.velocity.x = direction * speed * slowdown
	
	player.move_and_slide()
	
	return null
