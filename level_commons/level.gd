extends Node


@onready var animation_player = %AnimationPlayer
@onready var space_elevator_entry: SpaceElevator = %SpaceElevatorEntry
@onready var space_elevator_exit: SpaceElevator = %SpaceElevatorExit
@onready var entry_door: Door = %EntryDoor


func _ready():
	#TODO: Use GameState.get_deaths() to position player at last checkpoint
	if GameState.get_deaths() > 0:
		RespawnMechanic.respawn()
	else:
		space_elevator_entry.play_lift()
		await space_elevator_entry.lift_ended
	entry_door.open()

func _on_level_completed():
	animation_player.play("position_player_at_exit")
	await animation_player.animation_finished
	space_elevator_exit.play_lift()
	GameState.complete_level()

func _on_player_died(): 
	GameState.register_player_death()
	get_tree().reload_current_scene()

func _on_close_exit_door_area_body_entered(body):
	if body is Player:
		%ExitDoor.is_open = false

func _on_dev_settings_to_end_button_clicked():
	get_tree().get_first_node_in_group("player").global_position = %DebugEndLevelPositionMarker.global_position
