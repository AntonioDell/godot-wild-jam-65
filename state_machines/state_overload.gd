extends State

@export var state_ready_to_charge: State

#region Injectables

var animation_player: AnimationPlayer
var player_actions: PlayerActions

#endregion

@onready var explosion_audio: AudioStreamPlayer = %ExplosionAudio

var is_overload_finished = false
var stun_time = 0.0
var time_since_start = 0.0

func enter():
	player_actions.is_stunned = true
	time_since_start = 0.0
	
	var current_animation = animation_player.current_animation
	var direction = "left" if current_animation.ends_with("left") else "right"

	explosion_audio.play()
	var animation = animation_player.get_animation("overload_%s" % direction)
	stun_time = animation.length + .1
	animation_player.play("overload_%s" % direction)
	animation_player.queue("idle_%s" % direction)

func process_physics(delta: float) -> State:
	if time_since_start >= stun_time:
		return state_ready_to_charge
	
	time_since_start += delta
	return null

func exit():
	player_actions.is_stunned = false
