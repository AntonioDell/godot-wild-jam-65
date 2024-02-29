extends State


@export_group("States", "state_")
@export var state_idle: State
@export var state_drone_jump: State
@export var state_walking: State

#region Injectables

var player: CharacterBody2D
var player_actions: PlayerActions

#endregion

var drone_jump_triggered = false

func enter():
	if not "trigger_drone_jump" in player:
		push_error("Player doesn't have `trigger_drone_jump` signal!")
	else:
		player.trigger_drone_jump.connect(_trigger_drone_jump)

func process_physics(delta: float) -> State:
	if drone_jump_triggered:
		return state_drone_jump
	
	# TODO: Add input buffer to allow for walking input before landing
	if player.is_on_floor():
		if player_actions.get_movement_direction() != 0:
			return state_walking
		else:
			return state_idle
	
	# TODO: Play falling animation
	
	return null

func exit():
	player.trigger_drone_jump.disconnect(_trigger_drone_jump)
	drone_jump_triggered = false

func _trigger_drone_jump():
	drone_jump_triggered = true
