class_name Thrust
extends Node


@export var thrust_range_px: int
@export var thrust_range_curve: Curve
@export_range(.1, 5.0, 0.1) var thrust_duration: float

var t = 0
var velocity_list := [] 
var velocity_list_duration_k
var is_finished := false


func _ready():
	_recalculate_velocity_list()
	reset()

func reset():
	t = 0
	is_finished = false

## Can only be used in physics process
func get_thrust_velocity() -> float:
	if is_finished:
		push_error("get_thrust_velocity called while thrust is finished. This should not happen.")
		return 0.0
	
	var thrust = velocity_list[t]
	t += 1
	if t == velocity_list.size():
		is_finished = true

	return -thrust

func _sum(acc: float, next: float) -> float:
	return acc + next

func _recalculate_velocity_list():
	var bake_resolution = Engine.physics_ticks_per_second * thrust_duration # Will always be a whole number bc of .1 precision
	thrust_range_curve.bake_resolution = bake_resolution
	thrust_range_curve.bake()
	
	var i = 0.0
	var increment = 1 / float(bake_resolution)
	while i <= 1:
		if i == 0: 
			velocity_list.append(0.0)
			i += increment
			continue
		
		var f1 = thrust_range_curve.sample_baked(i)
		var f0 = thrust_range_curve.sample_baked(i - increment)
		velocity_list.append(f1 - f0)
		
		i += increment
	
	var sum = velocity_list.reduce(_sum, 0)
	var a = sum / float(thrust_range_px)
	velocity_list = velocity_list.map(func(value): return value / a) as Array[float]
	
