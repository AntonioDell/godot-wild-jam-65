extends CharacterBody2D

signal trigger_drone_jump

@onready var movement_state_machine: MovementStateMachine = %MovementStateMachine
@onready var rocket_state_machine: RocketStateMachine = %RocketStateMachine
@onready var player_actions: PlayerActions = %PlayerActions

func _ready():
	rocket_state_machine.init(player_actions)
	movement_state_machine.init(self, rocket_state_machine, player_actions)
