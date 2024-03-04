class_name PlayerActions
extends Node


# TODO: Prevent actions while stunned

func get_movement_direction() -> float:
	return Input.get_axis("move_left", "move_right")

func is_charging() -> bool:
	return Input.is_action_pressed("charge")
