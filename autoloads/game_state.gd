extends Node

enum {
	MAIN_MENU,
	LEVEL_1,
	END_LEVEL,
}
const SETTINGS = ["volume"]

## TODO: Keep updated with level count
@export var level_count = 3

var level_1_scene: PackedScene = preload("res://level_1/level_1.tscn")
var level_2_scene: PackedScene = preload("res://level_2/level_2.tscn")
var level_3_scene: PackedScene = preload("res://level_3/level_3.tscn")
var main_menu_scene: PackedScene = preload("res://main_menu/main_menu.tscn")
var current_level = 0
var settings = {
	"volume": .7,
}
var level_deaths = 0

var level_1_collected = false
var level_2_collected = false
var level_3_collected = false

@onready var canvas_modulate: CanvasModulate = %CanvasModulate

## Should be called after main menu animation finished
func start_game():
	level_1_collected = false
	level_2_collected = false
	level_3_collected = false
	current_level = 1
	_transition_to(LEVEL_1)

## Call on player death
func register_player_death():
	level_deaths += 1

func get_deaths():
	return level_deaths

## Call when player completed the current level
func complete_level():
	current_level += 1
	if current_level > level_count:
		# TODO: Show credits scene
		current_level = MAIN_MENU
		_transition_to(MAIN_MENU)
	else:
		_transition_to(current_level)

## Call if player collected a collectable
func collect_item():
	if current_level == 1:
		level_1_collected = true
	elif current_level == 2:
		level_2_collected = true
	elif current_level == 3:
		level_3_collected = true

func get_collected_count() -> int:
	var collected = [level_1_collected, level_2_collected, level_3_collected]
	return collected.count(true)

func change_setting(setting_name: String, value):
	if not SETTINGS.has(setting_name):
		push_error("%s failed to change setting %s. No setting with that name exists." % [name, setting_name])
	settings[setting_name] = value
	if setting_name == "volume":
		AudioManager.set_volume(value)
	# TODO: Actually apply audio to all audiostreams
# TODO: Reset level on death (reset collectibles got from the level)

const FADE_OUT_DURATION = 2.0
func _transition_to(level: int):
	_reset_level_state()
	
	var tween = create_tween()
	tween.tween_property(canvas_modulate, "color", Color.BLACK, FADE_OUT_DURATION)
	AudioManager.fade_out_music(FADE_OUT_DURATION)
	await tween.finished
	var error_code  
	if level != MAIN_MENU:
		error_code = get_tree().change_scene_to_packed(_get_level_scene(level))
	else:
		error_code = get_tree().change_scene_to_packed(main_menu_scene)
		
	if  level != MAIN_MENU and error_code != OK:
		# Try to change scene to main menu as error recovery
		push_error("%s failed to transition to level %s. Code %s" % [name, level, error_code])
		error_code = get_tree().change_scene_to_packed(main_menu_scene)
	if  error_code != OK:
		push_error("%s failed to transition to main menu. Code %s. Quitting game." % [name, error_code])
		get_tree().quit()
		return
	
	tween = create_tween()
	tween.tween_property(canvas_modulate, "color", Color.WHITE, .75)

func _get_level_scene(level: int) -> PackedScene:
	if level == 1:
		return level_1_scene
	if level == 2:
		return level_2_scene
	elif level == 3:
		return level_3_scene
	return null

func _reset_level_state():
	RespawnMechanic.reset()
	level_deaths = 0
