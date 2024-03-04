extends State

signal charging_started
signal rocket_thrust_activated(stage: int)


@export var state_charge_cooldown: State

@export var time_to_stage_1 := 0.6
@export var time_to_stage_2 := 1.6
@export var time_to_stage_3 := 2.3

#region Injectables

var player_actions: PlayerActions

#endregion

var charge_time = 0.0

func enter():
	charge_time = 0.0
	charging_started.emit()

func process_physics(delta: float) -> State:
	if not player_actions.is_charging():
		return state_charge_cooldown
	
	charge_time += delta
	return null

func exit():
	var stage = 0
	if charge_time >= time_to_stage_3:
		stage = 3
	elif charge_time >= time_to_stage_2:
		stage = 2
	elif charge_time >= time_to_stage_1:
		stage = 1
	
	rocket_thrust_activated.emit(stage)
