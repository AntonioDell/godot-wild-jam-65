extends State


#region Injectables

var player
var animation_player: AnimationPlayer

#endregion

func enter():
	(player as CharacterBody2D).velocity = Vector2.ZERO
	animation_player.play("death")
	await animation_player.animation_finished
	if "death_ended" in player:
		player.death_ended.emit()
