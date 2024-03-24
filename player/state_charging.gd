extends State

signal charging_started
signal charging_ended
signal rocket_thrust_activated(charge: float)


@export_group("States")
@export var state_charge_cooldown: State
@export var state_overload: State

@export_group("Charge")
@export var max_charge_time_seconds = 2.2 # = charge animation length + max_charge_delay
@export var max_charge_delay = .4 
@export var charge_level_2_reached_time = 1.2
@export var charge_level_3_reached_time = 1.8

@export_group("Audio")
@export var charge_audio_playback_position = 6.8
@export var charge_audio_playback_length = 12.0 - 6.8

@onready var charge_audio: AudioStreamPlayer = $ChargeAudio

#region Injectables

var player_actions: PlayerActions
var animation_player: AnimationPlayer

#endregion

var charge_time = 0.0
var is_overloaded = false

func enter():
	charge_time = 0.0
	charging_started.emit()
	charge_audio.pitch_scale = charge_audio_playback_length / max_charge_time_seconds
	charge_audio.play(charge_audio_playback_position)
	_animate_charge_start()

func process_physics(delta: float) -> State:
	if not player_actions.is_charging():
		_activate_thrust()
		return state_charge_cooldown
	
	if charge_time > max_charge_time_seconds:
		return state_overload
		
	if charge_time >= max_charge_time_seconds - max_charge_delay:
		_animate_charge_max()
	
	charge_time += delta
	return null

func exit():
	charge_audio.stop()
	charging_ended.emit()

func _activate_thrust():
	var charge = clampf(inverse_lerp(0.0, max_charge_time_seconds - max_charge_delay, charge_time), 0.1, 1.0)
	rocket_thrust_activated.emit(charge)
	var charge_level = 1
	if charge_time >= charge_level_3_reached_time:
		charge_level = 3
	elif charge_time >= charge_level_2_reached_time:
		charge_level = 2
	(get_node("Blastoff%sAudio" % charge_level) as AudioStreamPlayer).play()

func _animate_charge_start():
	var current_animation = animation_player.current_animation
	if current_animation.ends_with("left"):
		animation_player.play("charge_left")
	else:
		animation_player.play("charge_right")

func _animate_charge_max():
	var current_animation = animation_player.current_animation
	if current_animation.ends_with("left"):
		animation_player.play("max_charge_left")
	else:
		animation_player.play("max_charge_right")
