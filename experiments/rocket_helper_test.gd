extends Node

@onready var rocket_helper: RocketHelper = $RocketHelper
@onready var limit = Engine.physics_ticks_per_second * rocket_helper.seconds_to_max_height
@onready var character = $CharacterBody2D

func _ready():
	rocket_helper.init()

var i = 0
var sum = 0
func _physics_process(delta):
	if i >= limit:
		return
	var y = rocket_helper.get_next_velocity_y()
	character.velocity = Vector2(0, -y) * Engine.physics_ticks_per_second
	character.move_and_slide()
	i += 1
