extends State

@export var state_ready_to_charge: State
@export var time_to_cooldown := 1.0

var time_since_cooldown_started := 0.0

var player_actions: PlayerActions

func enter():
	time_since_cooldown_started = 0.0

func process_physics(delta: float) -> State:
	if time_since_cooldown_started >= time_to_cooldown:
		return state_ready_to_charge
	
	time_since_cooldown_started += delta
	return null
