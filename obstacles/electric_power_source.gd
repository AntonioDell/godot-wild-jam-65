@tool
extends StaticBody2D
class_name ElectricPowerSource

const FRAME_ACTIVE = 91
const FRAME_INACTIVE = 90

@export var is_active = true:
	set(value):
		is_active = value
		_update_sprite()

@onready var sprite: Sprite2D = $Sprite2D

func _update_sprite():
	if sprite:
		sprite.frame = FRAME_ACTIVE if is_active else FRAME_INACTIVE
	
