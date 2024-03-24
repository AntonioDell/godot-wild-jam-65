class_name RocketStateMachine
extends Node


signal max_charge_reached
signal rocket_thrust_activated(stage: int)


@onready var initial_state: State = $ReadyToCharge
@onready var state_overload: State = $Overload

var current_state: State

var is_charging := false
var last_charge := 0.0
## This prevents race conditions, when the state is changed from outside _physics_frame
var is_state_change_locked_for_frame = false

func init(player: CharacterBody2D, player_actions: PlayerActions, animation_player: AnimationPlayer):
	player.was_shot.connect(func(): _change_state_with_lock(state_overload))
	
	for child in get_children():
		if "player" in child:
			child.player = player
		if "player_actions" in child:
			child.player_actions = player_actions
		if "rocket_thrust_activated" in child:
			child.rocket_thrust_activated.connect(func(charge: float): 
				is_charging = false
				last_charge = charge
				rocket_thrust_activated.emit(charge))
		if "charging_started" in child:
			child.charging_started.connect(func(): is_charging = true)
		if "charging_ended" in child:
			child.charging_ended.connect(func(): is_charging = false)
		if "animation_player" in child:
			child.animation_player = animation_player
	
	current_state = initial_state
	is_charging = false


func _physics_process(delta):
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
		#print_debug("Change state %s -> %s" % [current_state.name, new_state.name])
		current_state.exit()
	
	current_state = new_state
	current_state.enter()

func _change_state_with_lock(new_state: State):
	_change_state(new_state)
	is_state_change_locked_for_frame = true

