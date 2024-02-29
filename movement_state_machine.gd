extends Node

@export var rocket_state_machine: RocketStateMachine

@export_group("States", "state_")
@export var state_initial: State
@export var state_rocket_thrust: State

@export var player_actions: PlayerActions

var current_state: State


func init(player: CharacterBody2D):
	rocket_state_machine.rocket_thrust_activated.connect(_on_rocket_thrust_activated)
	for child in get_children():
		child.player = player
		child.player_actions = player_actions
		child.rocket_state_machine = rocket_state_machine
	
	_change_state(state_initial)

func _physics_process(delta: float):
	var new_state = current_state.process_physics(delta)
	if new_state:
		_change_state(new_state)

func _change_state(new_state: State):
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

func _on_rocket_thrust_activated():
	_change_state(state_rocket_thrust)
