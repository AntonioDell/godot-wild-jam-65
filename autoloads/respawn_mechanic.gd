extends Node

@export var respawn_points: Array[RespawnPoint] = []

var past_respawn_positions: Array[Vector2] = []
var current_respawn_position: Vector2:
	set(value):
		if past_respawn_positions.has(value):
			# Respawn position was already reached -> do not add as current respawn position
			return
		GameState.make_collected_items_permanent()
		current_respawn_position = value
		past_respawn_positions.append(value)


func respawn():
	if current_respawn_position == Vector2.ZERO:
		push_error("%s configuration error: Called respawn before player reached the first respawn point." % [name])
		return
	
	var player: Player = get_tree().get_first_node_in_group("player")
	player.global_position = current_respawn_position

func register(respawn_point: RespawnPoint):
	respawn_point.respawn_point_reached.connect(_on_respawn_point_reached)

func reset():
	for point in respawn_points:
		point.respawn_point_reached.disconnect(_on_respawn_point_reached)
	respawn_points = []
	current_respawn_position = Vector2.ZERO

func _on_respawn_point_reached(respawn_position: Vector2):
	current_respawn_position = respawn_position
