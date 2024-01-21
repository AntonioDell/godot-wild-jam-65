@tool
extends Area2D


@export var time_stunned = 2.0
@export var is_shooty = false:
	set(value):
		is_shooty = value
		_update_shooty_area_color()

@onready var animation_player = %AnimationPlayer
@onready var stun_timer: Timer = %StunTimer
@onready var sprite: Sprite2D = %DroneSprites

var aim_directions: Dictionary = {
	"N": {"angle": INF, "frame": 7, "position": Vector2.ZERO },
	"NW": {"angle": INF, "frame": 9, "position": Vector2.ZERO },
	"W": {"angle": INF, "frame": 11, "position": Vector2.ZERO },
	"SW": {"angle": INF, "frame": 13, "position": Vector2.ZERO },
	"S": {"angle": INF, "frame": 15, "position": Vector2.ZERO },
	"SE": {"angle": INF, "frame": 17, "position": Vector2.ZERO },
	"E": {"angle": INF, "frame": 19, "position": Vector2.ZERO },
	"NE": {"angle": INF, "frame": 21, "position": Vector2.ZERO },
}
var colliding_player: Player
var shooty_player: Player
var current_aim: String
var bullet_scene = preload("res://obstacles/bullet.tscn")

func _ready():
	_update_shooty_area_color()
	if Engine.is_editor_hint(): return
	var bullet_origin_nodes = %BulletOrigins.get_children()
	for node: Node2D in bullet_origin_nodes:
		aim_directions[node.name].angle = %BulletOrigins.global_position.angle_to_point(node.global_position)
		aim_directions[node.name].position = node.global_position
		print("%s Angle %s" % [node.name, aim_directions[node.name].angle])
	_queue_idle()

func _process(delta):
	if Engine.is_editor_hint() or not colliding_player: return
	
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
	_queue_idle()

func _queue_idle():
	if not is_shooty:
		animation_player.queue("idle")
	else:
		animation_player.queue("idle_shooty")

func _on_player_entered(body):
	if body is Player:
		colliding_player = body

func _on_player_exited(body):
	if body is Player:
		colliding_player = null

func _aim_at_player():
	if not is_shooty or not shooty_player or not stun_timer.is_stopped(): return
	
	var player_pos = shooty_player.global_position
	var angle_to_player = %BulletOrigins.global_position.angle_to_point(player_pos)
	print("Angle to player %s" % angle_to_player)
	var smallest_difference_direction = Vector2.INF
	var smallest_difference = INF
	for direction: String in aim_directions:
		var difference = abs(angle_to_player - aim_directions[direction].angle)
		if difference  < smallest_difference:
			smallest_difference_direction = direction
			smallest_difference = difference
	
	sprite.frame = aim_directions[smallest_difference_direction].frame
	current_aim = smallest_difference_direction

func _shoot():
	if not is_shooty or not shooty_player or not current_aim or not stun_timer.is_stopped(): return
	
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.travel_angle = aim_directions[current_aim].angle
	bullet.global_position = aim_directions[current_aim].position
	get_tree().root.add_child(bullet)

func _on_shooty_player_detection_body_entered(body):
	if body is Player:
		shooty_player = body

func _on_shooty_player_detection_body_exited(body):
	if body is Player:
		shooty_player = null

#region tool scripts
const SHOOTY_AREA_COLOR = Color(255, 0, 0, .07)

func _update_shooty_area_color():
	if not Engine.is_editor_hint() or not %ShootyCollisionShape: return
	
	var shooty_collision_color = Color.TRANSPARENT if not is_shooty else SHOOTY_AREA_COLOR
	(%ShootyCollisionShape as CollisionShape2D).debug_color = shooty_collision_color
	
#endregion
