@tool
extends Node2D
class_name SpaceElevator

signal lift_ended

@export var flip_background = false:
	set(value):
		flip_background = value
		%SpaceBackgroundBottom.flip_v = flip_background

@onready var animation_player = %AnimationPlayer


func play_lift():
	animation_player.play("lift")
	await animation_player.animation_finished
	lift_ended.emit()
