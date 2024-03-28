extends State

@export var state_falling: State
@export var airborne_speed: float = 150.0
@export var thrust: Thrust

#region Injectables

var player: CharacterBody2D
var player_actions: PlayerActions

#endregion

func enter():
	thrust.reset()

func process_physics(delta: float) -> State:
	if player.is_on_ceiling():
		return state_falling
	
	var v_y = thrust.get_thrust_velocity() * Engine.physics_ticks_per_second
	
#region Ariborne walking 
	var v_x = player_actions.get_movement_direction() * airborne_speed
	player.velocity = Vector2(v_x, v_y)
#endregion
	
	if thrust.is_finished:
		return state_falling
	
	return null
