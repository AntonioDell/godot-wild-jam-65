@tool
extends Node2D

enum Orientation {
	VERTICAL,
	HORIZONTAL
}

@export var orientation: Orientation = 0:
	set(value):
		orientation = value
		_update_tiles()
@export var is_active = true:
	set(value):
		is_active = value
		_update_tiles()

@export_group("Control active elements")
@export var toggle_buttons: ToggleButtons
@export var toggle_buttons_active_index: int = 0


var electric_tiles: Array[ElectricTile] = []
var power_source_sprites: Array[ElectricPowerSource] = []

func _ready():
	_register_tiles()
	if toggle_buttons:
		toggle_buttons.button_pressed.connect(func (pressed_button: int): 
			is_active = pressed_button == toggle_buttons_active_index
		)
		is_active = toggle_buttons.pressed_button == toggle_buttons_active_index

func _register_tiles():
	var children = get_children()
	for child in children:
		if child is ElectricTile:
			electric_tiles.append(child)
		elif child is ElectricPowerSource:
			power_source_sprites.append(child)
	if Engine.is_editor_hint(): return
	
	if electric_tiles.size() == 0:
		push_error("%s configuration error: No electric tile exists in electic tile strip." % [name])
	if power_source_sprites.size() == 0:
		push_error("%s configuration error: No power source exists in electic tile strip." % [name])
	
	
func _update_tiles():
	for tile: ElectricTile in electric_tiles:
		tile.is_active = is_active
		tile.orientation = orientation
	for power_source: ElectricPowerSource in power_source_sprites:
		power_source.is_active = is_active
		
