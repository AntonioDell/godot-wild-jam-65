extends Node


@onready var animation_player = %AnimationPlayer


func _ready():
	#TODO: Use GameState.get_deaths() to position player at last checkpoint
	if GameState.get_deaths() > 0:
		RespawnMechanic.respawn()
	else:
		animation_player.play("level_start")

func _on_level_completed():
	animation_player.play("position_player_at_exit")
	animation_player.queue("level_end")
	await get_tree().create_timer(1.0).timeout
	GameState.complete_level()

func _on_player_died(): 
	GameState.register_player_death()
	get_tree().reload_current_scene()
	


func _on_close_exit_door_area_body_entered(body):
	if body is Player:
		%ExitDoor.is_open = false

