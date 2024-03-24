extends State

@export var state_idle: State

var player: CharacterBody2D

func process_physics(delta: float) -> State:
	player.move_and_slide()
	return state_idle
