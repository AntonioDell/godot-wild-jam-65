extends Node

@onready var music_player: AudioStreamPlayer = %MusicPlayer
@onready var sfx_player: AudioStreamPlayer = %SfxPlayer


var volume_db: float


func _ready():
	set_volume(GameState.settings.volume)


const MAX_VOLUME_DB = 0.0
const MIN_VOLUME_DB = -80.0

func set_volume(volume: float):
	volume_db = lerpf(MIN_VOLUME_DB, MAX_VOLUME_DB, volume)
	music_player.volume_db = volume_db
	sfx_player.volume_db = volume_db 


#region music
var main_menu_stream = preload("res://sound/solartitle.wav")
var level_1_stream = preload("res://sound/solar1final.wav")
var level_2_stream = preload("res://sound/solar2final.wav")
var level_3_stream = preload("res://sound/solar3final.wav")
func play_music(level: int):
	var next_stream: AudioStreamWAV
	match(level):
		0: next_stream = main_menu_stream
		1: next_stream = level_1_stream
		2: next_stream = level_2_stream
		3: next_stream = level_3_stream
	music_player.stop()
	music_player.stream = next_stream
	music_player.play()

func fade_out_music(duration: float):
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -40.0, duration)
	await tween.finished
	music_player.stop()
	music_player.volume_db = volume_db

func stop_music():
	music_player.stop()
#endregion

#region sfx
var results_loading_stream = preload("res://sound/ResultsLoading.wav")
var results_fail_stream = preload("res://sound/ResultsFail.wav")
var results_fine_stream = preload("res://sound/ResultsFine.wav")
var results_success_stream = preload("res://sound/ResultsSuccessWIthSfx.mp3")
func play_sfx_results():
	stop_music()
	# _play_sfx(results_loading_stream)
	# await sfx_player.finished   
	var collected_count = GameState.get_collected_count()
	if collected_count <= 1:
		_play_sfx(results_fail_stream)
	elif collected_count == 2:
		_play_sfx(results_fine_stream)
	else:
		_play_sfx(results_success_stream)

var door_stream = preload("res://sound/door_sound.wav")
func play_sfx_door():
	_play_sfx(door_stream)

func _play_sfx(sound_stream: AudioStream):
	if sfx_player.playing: return
	sfx_player.stream = sound_stream
	sfx_player.play()
	

#endregion
