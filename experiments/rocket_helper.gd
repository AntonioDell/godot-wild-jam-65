class_name RocketHelper
extends Node

@export var max_height: int
@export var movement_curve: Curve
@export_range(1.0, 5.0, 0.1) var seconds_to_max_height: float

var t = 0
var velocity_list := [] 


func init():
	movement_curve.bake_resolution = Engine.physics_ticks_per_second * seconds_to_max_height # Will always be a whole number bc of .1 precision
	movement_curve.bake()
	var i = 0.0
	var increment = 1 / float(movement_curve.bake_resolution)
	while i <= 1:
		if i == 0: 
			velocity_list.append(0.0)
			i += increment
			continue
		
		var f1 = movement_curve.sample_baked(i)
		var f0 = movement_curve.sample_baked(i - increment)
		velocity_list.append(f1 - f0)
		
		i += increment
	
	var sum = velocity_list.reduce(_sum, 0)
	var a = sum / float(max_height)
	velocity_list = velocity_list.map(func(value): return value / a) as Array[float]
	reset()

func reset():
	t = 0

func get_next_velocity_y() -> float:
	if t >= velocity_list.size():
		push_error("get_next_velocity_y called before reset(). This should not happen")
		return 0.0
	
	var ret = velocity_list[t]
	t += 1
	return ret

func _sum(acc: float, next: float) -> float:
	return acc + next
