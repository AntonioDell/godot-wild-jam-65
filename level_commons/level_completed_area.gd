extends Area2D

signal level_completed

func _on_body_entered(body):
	if body is Player or body is FiniteStatePlayer:
		level_completed.emit()
