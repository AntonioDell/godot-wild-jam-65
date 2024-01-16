extends Area2D

@export var time_stunned = 2.0

@onready var animation_player = %AnimationPlayer
@onready var stun_timer: Timer = %StunTimer

var colliding_player: Player

func _process(delta):
	if not colliding_player: return
	if colliding_player.velocity.y > 0 and stun_timer.is_stopped():
		# Player is currently colliding AND falling AND drone is not stunned
		_trigger_drone_jump()

func _trigger_drone_jump():
	colliding_player.drone_triggered_jump.start()
	animation_player.play("stun_start_end")
	animation_player.queue("stun_loop")
	stun_timer.start(time_stunned)
	
	await stun_timer.timeout
	
	animation_player.play("stun_start_end")
	animation_player.queue("idle")

func _on_player_entered(body):
	print(body)
	if body is Player:
		colliding_player = body

func _on_player_exited(body):
	if body is Player:
		colliding_player = null
