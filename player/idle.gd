extends State

@export var state_walking: State 
@export var state_falling: State

#region Injectables

var player_actions: PlayerActions
var player: CharacterBody2D

#endregion

func process_physics(delta: float) -> State:
	if not player.is_on_floor(): return state_falling
	if player_actions.get_movement_direction() != 0: return state_walking
	
	# TODO: Play idle animation
	
	return null
