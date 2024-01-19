extends Node

enum {
	MAIN_MENU,
	LEVEL_1,
	END_LEVEL,
}
const SETTINGS = ["volume"]

@export var level_count = 2

var level_1_scene: PackedScene = preload("res://level_1/level_1.tscn")
var level_3_scene: PackedScene = preload("res://level_3/level_3.tscn")
var main_menu_scene: PackedScene = preload("res://main_menu/main_menu.tscn")
var collected_items = 0
var collected_items_in_level = 0
var current_level = 0
var settings = {
	"volume": .5
}

@onready var canvas_modulate: CanvasModulate = %CanvasModulate

## Should be called after main menu animation finished
func start_game():
	current_level = 1
	collected_items = 0
	_transition_to(LEVEL_1)

## Call on player death
func restart_level():
	collected_items_in_level.clear()
	var tween = create_tween()
	tween.tween_property(canvas_modulate, "color", Color.BLACK, 3.0)
	await tween.finished
	get_tree().reload_current_scene()
	tween.tween_property(canvas_modulate, "color", Color.WHITE, 1.0)

## Call when player completed the current level
func complete_level():
	current_level += 1
	collected_items += collected_items_in_level
	collected_items_in_level = 0
	if current_level > level_count:
		# TODO: Show credits scene
		current_level = MAIN_MENU
		collected_items = 0
		_transition_to(MAIN_MENU)
	else:
		_transition_to(current_level)

## Call if player collected a collectable
func collect_item():
	collected_items_in_level += 1

func get_collected_count() -> int:
	return collected_items

func change_setting(setting_name: String, value):
	if not SETTINGS.has(setting_name):
		push_error("%s failed to change setting %s. No setting with that name exists." % [name, setting_name])
	settings[setting_name] = value
	# TODO: Actually apply audio to all audiostreams
# TODO: Reset level on death (reset collectibles got from the level)

func _transition_to(level: int):
	var tween = create_tween()
	tween.tween_property(canvas_modulate, "color", Color.BLACK, 3.0)
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
	tween.tween_property(canvas_modulate, "color", Color.WHITE, 1.0)

## TODO: Adjust to fit level 2
func _get_level_scene(level: int) -> PackedScene:
	if level == 1:
		return level_1_scene
	elif level == 2:
		return level_3_scene
	return null
