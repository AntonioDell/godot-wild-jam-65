extends Node

@onready var animation_player = %AnimationPlayer

enum {
	STATE_NOTHING,
	STATE_INSUFFICIENT,
	STATE_FINE,
	STATE_RADICAL
}

func _ready():
	# FIXME: Remove
	await get_tree().create_timer(2.0).timeout
	_end_game()

# TODO: Only execute when player reaches end of level 
func _end_game():
	var machine_state = GameState.get_collected_count()
	
	if machine_state == STATE_NOTHING:
		animation_player.play("nothing")
	elif machine_state == STATE_INSUFFICIENT:
		animation_player.play("insufficient")
	elif machine_state == STATE_FINE:
		animation_player.play("fine")
	else:
		animation_player.play("radical")
	
	await animation_player.animation_finished
	
	GameState.complete_level()
