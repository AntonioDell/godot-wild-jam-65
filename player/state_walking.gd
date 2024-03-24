extends State

@export var state_falling: State
@export var state_idle: State
@export var state_jump: State

@export var speed := 150.0
@export var charge_slowdown := 0.05

#region Injectables

var player: CharacterBody2D
var animation_player: AnimationPlayer
var player_actions: PlayerActions
var rocket_state_machine: RocketStateMachine

#endregion

var is_jumping = false
func enter():
	is_jumping = false
	player_actions.jump_triggered.connect(_on_jump_triggered)

func process_physics(delta: float) -> State:
	if is_jumping: return state_jump
	if not player.is_on_floor():
		return state_falling
	
	var direction = player_actions.get_movement_direction()
	if direction == 0 and player.get_last_slide_collision() and is_zero_approx(player.get_last_slide_collision().get_travel().length_squared()):
		return state_idle

	var slowdown = charge_slowdown if rocket_state_machine.is_charging else 1.0
	# TODO: Play walking animation
	# TODO: Add acceleration and deceleration
	player.velocity.x = direction * speed * slowdown
	
	_animate(direction)
	
	return null

func exit():
	player_actions.jump_triggered.disconnect(_on_jump_triggered)
	player.velocity.x = 0
	#animation_player.clear_queue()

func _on_jump_triggered():
	is_jumping = true

func _animate(direction: float):
	if rocket_state_machine.is_charging: return 
	
	var next_animation = ""
	if sign(direction) > 0:
		next_animation = "walk_right"
	elif sign(direction) < 0:
		next_animation = "walk_left"
	
	var current_animation = animation_player.current_animation
	if current_animation == "turn": return
	elif next_animation.is_empty(): return
	elif current_animation == next_animation: return
	
	var should_turn = (current_animation.ends_with("left") and next_animation == "walk_right") \
		or (current_animation.ends_with("right") and next_animation == "walk_left")
	if should_turn:
		animation_player.play("turn")
		animation_player.queue(next_animation)
	else:
		animation_player.play(next_animation)
	
	
