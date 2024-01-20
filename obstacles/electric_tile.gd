@tool
extends Area2D
class_name ElectricTile

const FRAME_H_ACTIVE = 67
const FRAME_H_INACTIVE = 79
const FRAME_V_ACTIVE = 92
const FRAME_V_INACTIVE = 93

enum Orientation {
	VERTICAL,
	HORIZONTAL
}

@export var orientation: Orientation = 0:
	set(value):
		orientation = value
		_update_sprite()
@export var is_active = true:
	set(value):
		is_active = value
		_update_sprite()

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	_update_sprite()

func _on_body_entered(body):
	if Engine.is_editor_hint(): return
	
	if body is Player and is_active:
		(body as Player).die()

func _update_sprite():
	if sprite:
		if orientation == Orientation.VERTICAL:
			sprite.frame = FRAME_V_ACTIVE if is_active else FRAME_V_INACTIVE
		else:
			sprite.frame = FRAME_H_ACTIVE if is_active else FRAME_H_INACTIVE
	
