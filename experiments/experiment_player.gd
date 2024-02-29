extends CharacterBody2D


@export var walking_speed = 150.0

# TODO: Rocket with charging
#	-> params: max achievable height with charge, 
const TILE_HEIGHT = 32

@export var rocket_time_to_max_charge: float = 2.2
@export var rocket_time_to_overload: float = 2.0
@export var rocket_max_height: float = TILE_HEIGHT * 10
@export var rocket_time_to_peak: float = 1.0


# TODO: Drone bounce
# 	-> Add little pause before lift off to show player what is happening

# TODO: Fall from ledge
#	-> shouldn't be much different from other gravity ??? 

@onready var fall_gravity: float = 100.0
# TODO: 0 gravity time at peaks of vertical upward movements (rocket, drone bounce)
@export var zero_gravity_time: float = .5

# TODO: Coyote time

# TODO: Ground movement (acceleration, decelaration)
# TODO: Input buffering for rocket charge
# TODO: Rocket overload explosion (loooong time before it actually happens -> easter egg)
# TODO: Second movement mode: Rocket without charging -> instant liftoff -> overcharge when it is too long active

enum {
	IDLE,
	WALKING,
	ROCKET_START_CHARGING,
	ROCKET_CHARGING,
	ROCKET_START,
	ROCKET_ACTIVE,
	ROCKET_OVERLOAD,
	FALLING
}

var state = IDLE

func _physics_process(delta):
	match(state):
		IDLE:
			_process_idle(delta)
		WALKING:
			_process_walking(delta)
		ROCKET_START_CHARGING: 
			_process_rocket_start_charging(delta)
		ROCKET_CHARGING: 
			_process_rocket_charging(delta)
		ROCKET_START:
			_process_rocket_start(delta)
		ROCKET_ACTIVE:
			_process_rocket_active(delta)
		ROCKET_OVERLOAD:
			_process_rocket_overload(delta)
		FALLING:
			_process_falling(delta)

func _process_idle(delta: float):
	if Input.is_action_pressed("charge"):
		_change_state(ROCKET_START_CHARGING)
		return
	if not is_on_floor():
		_change_state(FALLING)
		return
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		_change_state(WALKING)
		return
	

func _process_walking(delta: float):
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	velocity.x = horizontal_direction * walking_speed
	move_and_slide()
	
	if is_zero_approx(horizontal_direction):
		_change_state(IDLE)
		return
	if Input.is_action_pressed("charge"):
		velocity.x = 0.0
		_change_state(ROCKET_START_CHARGING)
		return

var charging_time: float = 0.0
var next_charge = 0.0
func _process_rocket_start_charging(delta: float):
	# TODO: Add cooldown
	next_charge = 0.0
	charging_time = 0.0
	_change_state(ROCKET_CHARGING)

func _process_rocket_charging(delta: float):
	# TODO: Remove debug code
	if not Input.is_action_pressed("charge") or charging_time >= rocket_time_to_max_charge + rocket_time_to_overload:
		next_charge = clampf(inverse_lerp(0.0, rocket_time_to_max_charge, charging_time), 0.1, 1.0)
		print(next_charge)
		_change_state(ROCKET_START)
		return
	
	charging_time += delta
	
	# TODO: Add overload stuff
	#if charging_time >= ... :
	#	_change_state(ROCKET_OVERLOAD)
	
	# TODO: Play charging animation and loop max charge for `rocket_time_to_overload` seconds

func _process_rocket_start(delta: float):
	var rocket_velocity = (((2.0 * (rocket_max_height * next_charge)) / (rocket_time_to_peak * next_charge)) * -1.0) 
	velocity.y = rocket_velocity
	move_and_slide()
	
	_change_state(ROCKET_ACTIVE)

const MAX_TILT = PI * .25
@export var tilt_time_to_max: float = 1.0

## In rad/s -> https://www.omnicalculator.com/physics/angular-velocity
var tilt_speed = MAX_TILT / tilt_time_to_max

var tilt = 0.0
var rocket_gravity: float = 0.0
func _process_rocket_active(delta: float):
	if rocket_gravity == 0.0:
		var time_to_peak = rocket_time_to_peak * next_charge
		rocket_gravity = ((-2.0 * rocket_max_height) / (time_to_peak * time_to_peak)) * -1.0
	
	var tilt_direction = Input.get_axis("move_left", "move_right")
	tilt = clampf(tilt + (tilt_direction * tilt_speed * delta), -MAX_TILT , MAX_TILT)
	
	# TODO: 
	var new_velocity = velocity + Vector2(0, rocket_gravity * delta).rotated(-tilt)
	velocity = new_velocity
	
	# TODO: Remove old code
	# velocity.y += rocket_gravity * delta
	
	# TODO: Rocket tilting for airborne navigation
#	-> How does airborne navigation work when rockets are off?
#	-> Probably like ground movement
	
	# TODO: Edge nudging (horizontal and vertical)
	move_and_slide()
	
	if velocity.y >= 0.0:
		next_charge = 0.0
		rocket_gravity = 0.0
		tilt = 0.0
		_change_state(FALLING)

func _process_rocket_overload(delta: float):
	# TODO: Add overload stuff
	_change_state(IDLE)
	pass

func _process_falling(delta: float):
	if is_on_floor():
		_change_state(IDLE)
		return
	
	# TODO: ROCKET_CHARGING_START should be reachable here to achieve mid-air rocket jump
	
	# TODO: This needs to work for minus values
	velocity.x -= delta * sign(velocity.x)
	# TODO: Fall gravity needs to increase until a maximum
	velocity.y += fall_gravity * delta # This increases y velocity until infinity
	
	move_and_slide()

func _change_state(new_state: int):
	print("_change_state to %s" % new_state)
	state = new_state
