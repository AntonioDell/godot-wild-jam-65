class_name RocketStateMachine
extends Node


signal rocket_thrust_activated(stage: int)


@onready var initial_state: State = $ReadyToCharge

var current_state: State

var is_charging := false

func init(player_actions: PlayerActions):
	for child in get_children():
		if "player_actions" in child:
			child.player_actions = player_actions
		if "rocket_thrust_activated" in child:
			child.rocket_thrust_activated.connect(func(stage: int): 
				is_charging = false
				rocket_thrust_activated.emit(stage))
		if "charging_started" in child:
			child.charging_started.connect(func(): is_charging = true)
	
	current_state = initial_state
	is_charging = false


func _physics_process(delta):
	var new_state = current_state.process_physics(delta)
	if new_state:
		_change_state(new_state)

func _change_state(new_state: State): 
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()
