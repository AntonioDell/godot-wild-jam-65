extends CharacterBody2D


@export var rocket_with_decimals: RocketWithDecimals


var charge_animation_playback_speed = 1.0

@onready var rocket_sprites = %RocketSprites
@onready var robot_sprites = %RobotSprites
@onready var animation_player = %AnimationPlayer


func _ready():
	var charge_animation_length = animation_player.get_animation("charge").length
	charge_animation_playback_speed = charge_animation_length / rocket_with_decimals.max_charge_time_seconds
	rocket_with_decimals.charging_started.connect(_on_rocket_charging_started)
	rocket_with_decimals.rocket_started.connect(_on_rocket_started)

func _physics_process(delta):
	move_and_slide()

func _process(delta: float):
	var horizontal_velocity = _get_horizontal_velocity(delta)
	var vertical_velocity = rocket_with_decimals.get_vertical_velocity(delta, is_on_floor()) 
	
	velocity = horizontal_velocity + vertical_velocity

func _get_horizontal_velocity(delta: float):
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	if horizontal_direction < 0:
		rocket_sprites.flip_h = true
		robot_sprites.flip_h = true
	elif horizontal_direction > 0: 
		rocket_sprites.flip_h = false
		robot_sprites.flip_h = false
		
	return Vector2.RIGHT * horizontal_direction * 100.0

func _on_rocket_charging_started():
	animation_player.play("charge", -1, charge_animation_playback_speed)

func _on_rocket_started():
	animation_player.stop()
