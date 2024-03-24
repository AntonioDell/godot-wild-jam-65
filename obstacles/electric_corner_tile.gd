@tool
extends Area2D
class_name ElectricCornerTile

const FRAME_1_ACTIVE = 0
const FRAME_2_ACTIVE = 1
const FRAME_3_ACTIVE = 4
const FRAME_4_ACTIVE = 5

@export_range(0, 3) var orientation: int = 0:
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
	
	if "die" in body and is_active:
		body.die()

func _update_sprite():
	if not sprite: return
	
	var active_frame
	match orientation:
		0: active_frame = FRAME_1_ACTIVE
		1: active_frame = FRAME_2_ACTIVE
		2: active_frame = FRAME_3_ACTIVE
		3: active_frame = FRAME_4_ACTIVE
	if is_active:
		sprite.frame = active_frame
	else:
		sprite.frame = active_frame + 2
	
