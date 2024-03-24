extends Area2D

func _on_body_entered(body):
	if not body is Player and not body is FiniteStatePlayer: return
	
	GameState.collect_item()
	# TODO: Add some animation on collecting
	queue_free()
