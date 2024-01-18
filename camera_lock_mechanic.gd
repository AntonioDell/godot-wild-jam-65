@tool
extends Node
class_name DeathMechanic

@export var lock_camera_heights: Array[float] = []

var player: Player
var current_height_index: int = -1

func _ready():
	if Engine.is_editor_hint(): return
	
	player = get_tree().get_first_node_in_group("player") as Player
	if not player:
		push_error("%s configuration error: No player exists in tree" % name)
	
	lock_camera_heights.sort()
	lock_camera_heights.reverse()
	if lock_camera_heights.size() == 0:
		push_error("%s configuration error: No heights set" % name)
	else:
		current_height_index = 0

func _process(delta):
	_tool_show_debug_lines()
	if Engine.is_editor_hint() or current_height_index == -1: return
	
	# FIXME: This will not work if the player doesn't touch the floor
	if player.global_position.y < lock_camera_heights[current_height_index] and player.is_on_floor():
		# TODO: Lock camera at height and kill player if he falls outside
		_change_camera_limit(lock_camera_heights[current_height_index])
		current_height_index = clampi(current_height_index + 1, 0, lock_camera_heights.size() - 1)
		

var tween
func _change_camera_limit(new_limit: int):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(player.camera, "limit_bottom", new_limit, 2.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

#region tool scripts

var debug_lines: Array[Line2D] = []

func _tool_show_debug_lines():
	if not Engine.is_editor_hint(): return
	if not _tool_should_recreate_lines(): return
	print_debug("%s _tool_show_debug_lines executing" % name)
	
	for line in debug_lines:
		line.queue_free()
	debug_lines.clear()
	
	var width = get_viewport().size.x
	for height in lock_camera_heights:
		debug_lines.append(_tool_create_debug_line(height, width))
		
	print_debug("%s _tool_show_debug_lines created %s lines" % [name, debug_lines.size()])

func _tool_should_recreate_lines() -> bool:
	if debug_lines.size() == 0 and lock_camera_heights.size() == 0: return false
	elif debug_lines.size() != lock_camera_heights.size(): return true
	
	var all_lines_exist = debug_lines.all(func(line: Line2D): 
		return lock_camera_heights.has(line.points[0].y))
	return not all_lines_exist

func _tool_create_debug_line(height: float, width: int) -> Line2D:
	var line = Line2D.new()
	line.width = 2
	line.default_color = Color.DARK_RED
	line.add_point(Vector2(0, height))
	line.add_point(Vector2(width, height))
	add_child(line)
	
	return line

#endregion
