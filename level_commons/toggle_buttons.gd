@tool
extends Node2D
class_name ToggleButtons


signal button_pressed(key: int)


@export var buttons: Array[ButtonArea] = [null, null]

var pressed_button: int


func _ready():
	for i in buttons.size():
		var button = buttons[i]
		button.button_pressed.connect(_on_button_pressed.bind(i))
		if button.is_pressed:
			pressed_button = i

func _process(delta):
	_tool_show_debug_lines()

func _on_button_pressed(pressed_button_index: int):
	for i in buttons.size(): 
		if i == pressed_button_index: continue
		var button = buttons[i]
		if button.is_pressed:
			button.is_pressed = false
	
	pressed_button = pressed_button_index
	button_pressed.emit(pressed_button)

#region tool scripts

var debug_line: Line2D

## Connect buttons by line in editor
func _tool_show_debug_lines():
	if not Engine.is_editor_hint(): return
	if not _tool_should_recreate_line(): return
	print_debug("%s _tool_show_debug_lines executing" % name)
	
	if debug_line:
		debug_line.queue_free()
		
	# TODO: Make work with multiple buttons
	debug_line = Line2D.new()
	debug_line.width = 1
	debug_line.default_color = Color.DARK_GOLDENROD
	debug_line.add_point(buttons[0].global_position)
	debug_line.add_point(buttons[1].global_position)
	add_child(debug_line, false, Node.INTERNAL_MODE_FRONT)

func _tool_should_recreate_line() -> bool:
	if buttons.size() != 2: return false
	elif not debug_line or debug_line.points.size() != 2: return true
	else:
		return debug_line.points[0] != buttons[0].global_position or debug_line.points[1] != buttons[1].global_position

#endregion
