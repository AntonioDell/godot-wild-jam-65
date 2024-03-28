extends Node

@export var level_number = 3 

@onready var animation_player = %AnimationPlayer
@onready var space_elevator_entry: SpaceElevator = %SpaceElevatorEntry
@onready var entry_door: Door = %EntryDoor

enum {
	STATE_NOTHING,
	STATE_INSUFFICIENT,
	STATE_FINE,
	STATE_RADICAL
}

func _ready():
	#TODO: Use GameState.get_deaths() to position player at last checkpoint
	if GameState.get_deaths() > 0:
		RespawnMechanic.respawn()
	else:
		space_elevator_entry.play_lift()
		await space_elevator_entry.lift_ended
		AudioManager.play_music(level_number)
	entry_door.open()

func _on_end_reached_area_body_entered(body):
	if body is Player or body is FiniteStatePlayer:
		_end_game()

func _end_game():
	var player = get_tree().get_first_node_in_group("player")
	player.animation_player.play("idle_left")
	player.camera.enabled = false
	%EndCamera.enabled = true
	
	AudioManager.play_sfx_results()
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
	await get_tree().create_timer(2.0).timeout
	
	GameState.complete_level()

func _on_player_died(): 
	GameState.register_player_death()
	get_tree().reload_current_scene()

func _on_dev_settings_to_end_button_clicked():
	get_tree().get_first_node_in_group("player").global_position = %DebugEndLevelPositionMarker.global_position

func _on_first_button_pressed():
	($FirstDoor as Door).open()
	(%FirstElectricTileStrip as ElectricTileStrip).is_active = true

func _on_free_or_capture_toggle_buttons_button_pressed(key):
	if key == 0: # Button B is pressed
		(%FreeDroneDoorTop as Door).open()
		(%FreeDroneDoorBottom as Door).close()
	else: # Button A is pressed
		(%FreeDroneDoorTop as Door).close()
		(%FreeDroneDoorBottom as Door).open()


