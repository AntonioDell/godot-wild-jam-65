extends Area2D
class_name Bullet

@export var travel_angle: float
@export var speed: float = 200.0

@onready var direction = Vector2.from_angle(travel_angle)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if "_explode" in body:
		body._explode()
	elif "bullet_hit" in body:
		body.bullet_hit()
	queue_free()

func _on_area_entered(area):
	queue_free()
