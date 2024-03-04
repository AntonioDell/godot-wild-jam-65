class_name MovementStateMachine
extends Node


@onready var state_initial: State = $Idle
@onready var state_rocket_active: State = $RocketActive

## This prevents race conditions, when the state is changed from outside _physics_frame
var is_state_change_locked_for_frame = false
var current_state: State

func init(player: CharacterBody2D, rocket_state_machine: RocketStateMachine, player_actions: PlayerActions):
	rocket_state_machine.rocket_thrust_activated.connect(_on_rocket_thrust_activated)
	for child in get_children():
		if "player" in child:
			child.player = player
		if "player_actions" in child:
			child.player_actions = player_actions
		if "rocket_state_machine" in child:
			child.rocket_state_machine = rocket_state_machine
	
	_change_state(state_initial)

func _physics_process(delta: float):
	is_state_change_locked_for_frame = false
	
	var new_state = current_state.process_physics(delta)
	if new_state:
		_change_state(new_state)

func _change_state(new_state: State):
	if is_state_change_locked_for_frame: 
		is_state_change_locked_for_frame = false
		push_warning("Tried to change state while locked. %s -> %s" % [current_state.name, new_state.name])
		return
	
	if current_state:
		print_debug("Change state %s -> %s" % [current_state.name, new_state.name])
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

func _on_rocket_thrust_activated(stage: int):
	_change_state(state_rocket_active)
	is_state_change_locked_for_frame = true
