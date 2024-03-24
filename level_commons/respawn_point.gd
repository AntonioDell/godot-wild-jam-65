extends Area2D
class_name RespawnPoint

signal respawn_point_reached(respawn_position: Vector2)


func _ready():
	RespawnMechanic.register(self)


func _on_body_entered(body):
	if body is Player or body is FiniteStatePlayer:
		respawn_point_reached.emit(global_position)
