extends Node

@onready var player: FiniteStatePlayer = $FiniteStatePlayer

func _ready():
	player.death_ended.connect(_on_player_died)

func _on_player_died():
	get_tree().reload_current_scene()
