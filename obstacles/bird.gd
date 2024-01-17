@tool
extends CharacterBody2D
class_name Bird

@export var patrol_point_nodes: Array[Node2D] = []
@export var speed = 100.0
@export var patrol_point_reached_error_margin = 1.0

@onready var animation_player = %AnimationPlayer
@onready var sprite: Sprite2D = %BirdSprites

var patrol_points: Array[Vector2] = []

func get_sucked_in(direction: Vector2):
	# TODO: Move toward direction
	animation_player.play("poof")
	await animation_player.animation_finished
	queue_free()

var current_patrol_point: int = -1
func _ready():
	if not Engine.is_editor_hint():
		%DebugPatrolPath.hide()
	else:
		%DebugPatrolPath.show()
	_tool_update_debug_path()
	_reset_patrol_points()

func _physics_process(delta):
	_move_on_patrol(delta)
	move_and_slide()

func _process(delta):
	_tool_update_debug_path()

func _reset_patrol_points():
	patrol_points = []
	for node in patrol_point_nodes:
		patrol_points.append(node.global_position)
	
	if Engine.is_editor_hint(): return
	if patrol_points.size() <= 1: 
		push_warning("Bird '%s' doesn't have patrol points set." % [name])
		return
	current_patrol_point = 1

func _move_on_patrol(delta: float):
	if Engine.is_editor_hint(): return
	
	if current_patrol_point == -1: return
	
	var direction = patrol_points[current_patrol_point] - global_position
	if abs(direction.length_squared()) < patrol_point_reached_error_margin:
		current_patrol_point = wrapi(current_patrol_point + 1, 0, patrol_points.size())
		direction = patrol_points[current_patrol_point] - global_position
		sprite.flip_h = direction.x < 0
	
	# TODO: Make flight movement more natural
	velocity = direction.normalized() * speed


# tool functions
func _tool_update_debug_path():
	if not Engine.is_editor_hint(): 
		return
	if not patrol_point_nodes.all(func (node): return patrol_points.has(node.global_position)):
		_reset_patrol_points()
		_tool_draw_patrol_path()
	
func _tool_draw_patrol_path():
	if not Engine.is_editor_hint(): return
	
	%DebugPatrolPath.clear_points()
	for node in patrol_point_nodes:
		%DebugPatrolPath.add_point(node.position)
