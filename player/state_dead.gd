extends State


#region Injectables

var player
var animation_player: AnimationPlayer

#endregion

func enter():
	animation_player.play("death")
	await animation_player.animation_finished
	print("Death ended")
	if "death_ended" in player:
		print(".. and emitted")
		player.death_ended.emit()
