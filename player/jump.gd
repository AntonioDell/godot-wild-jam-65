extends Node
class_name Jump

signal jump_started()
signal jump_ended()

@export var max_jump_duration = .2
@export var max_jump_speed = 500.0

var is_jumping = false

@onready var timer: Timer = $Timer

func _ready():
	$Timer.timeout.connect(_end_jump)

func start():
	jump_started.emit()
	timer.start(max_jump_duration)
	is_jumping = true

func get_vertical_velocity(delta: float) -> Vector2:
	var ret = Vector2.ZERO
	if is_jumping:
		var strength = max_jump_speed * inverse_lerp(0.0, max_jump_duration, timer.time_left)
		ret = Vector2.UP * strength
	
	return ret

func _end_jump():
	jump_ended.emit()
	is_jumping = false
