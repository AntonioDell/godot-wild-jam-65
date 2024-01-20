extends AnimatableBody2D

@onready var animation_player = %AnimationPlayer 

func play_move_animation():
	animation_player.play("move")

func stop_move_animation():
	animation_player.play("idle")
