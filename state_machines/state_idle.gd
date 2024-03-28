extends State

@export var state_walking: State 
@export var state_falling: State
@export var state_jump: State

#region Injectables

var player_actions: PlayerActions
var animation_player: AnimationPlayer
var player: CharacterBody2D
var rocket_state_machine: RocketStateMachine

#endregion

var is_jumping = false

func enter():
	is_jumping = false
	player_actions.jump_triggered.connect(_on_jump_triggered)
	_animate()

func process_physics(delta: float) -> State:
	if is_jumping: return state_jump
	elif not player.is_on_floor(): return state_falling
	elif player_actions.get_movement_direction() != 0: return state_walking
	
	return null

func exit():
	player_actions.jump_triggered.disconnect(_on_jump_triggered)

func _on_jump_triggered():
	is_jumping = true

func _animate():
	if rocket_state_machine.is_charging: return
	
	var current_animation = animation_player.current_animation
	if current_animation == "turn":
		await animation_player.animation_changed
		current_animation = animation_player.current_animation
	elif current_animation.begins_with("overload_"):
		await animation_player.animation_changed
	
	if current_animation.ends_with("left"):
		animation_player.play("idle_left")
	elif current_animation.ends_with("right"):
		animation_player.play("idle_right")
