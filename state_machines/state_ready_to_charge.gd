extends State

@export var state_charging: State

#region Injectables

var player_actions: PlayerActions

#endregion


func process_physics(delta: float) -> State:
	if player_actions.is_charging():
		return state_charging
	
	return null
