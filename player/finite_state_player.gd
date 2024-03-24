class_name FiniteStatePlayer
extends CharacterBody2D

signal was_shot
signal trigger_drone_jump
signal death_started
signal death_ended

@onready var movement_state_machine: MovementStateMachine = %MovementStateMachine
@onready var rocket_state_machine: RocketStateMachine = %RocketStateMachine
@onready var player_actions: PlayerActions = %PlayerActions
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var camera: Camera2D = $Camera

func _ready():
	rocket_state_machine.init(self, player_actions, animation_player)
	movement_state_machine.init(self, rocket_state_machine, player_actions, animation_player)

func die():
	death_started.emit()

func bullet_hit():
	was_shot.emit()


func _on_bird_stun_collision_area_body_entered(body):
	(body as Bird).get_sucked_in(Vector2.ZERO)
	bullet_hit()
