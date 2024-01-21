@tool
extends Area2D
class_name ElectricTileStrip

enum Orientation {
	VERTICAL,
	HORIZONTAL
}

@export var is_active = true:
	set(value):
		is_active = value
		_update_tiles()

@export_group("Control active elements")
@export var toggle_buttons: ToggleButtons
@export var toggle_buttons_active_index: int = 0


var active_switchable_tiles: Array[Node2D] = []


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
		if "is_active" in child:
			active_switchable_tiles.append(child)
	if Engine.is_editor_hint(): return
	
	if active_switchable_tiles.size() == 0:
		push_error("%s configuration error: No active swtichable tiles exists in electic tile strip." % [name])
	
	
func _update_tiles():
	for tile in active_switchable_tiles:
		tile.is_active = is_active
		
