class_name PlayerActions
extends Node


func get_movement_direction() -> float:
	return Input.get_axis("move_left", "move_right")
