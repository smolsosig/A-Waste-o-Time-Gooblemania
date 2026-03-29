extends Node

# Let's be clear: we're only using this MusicManager for music in-game, ja?
# This shit is complicated when used outside of the game stage. Too many bugs.
# Too little time and energy for me to care.

@export var music_volume : float = 0.96

@onready var primary: AudioStreamPlayer = get_node("%Primary")
@onready var secondary: AudioStreamPlayer = get_node("%Secondary")
@onready var misc: AudioStreamPlayer = get_node("%Misc")
@onready var jingle: AudioStreamPlayer = get_node("%Jingle")
@onready var players: Array = [primary, secondary, misc, jingle]

@onready var soundscapes: Array = [get_node("%Soundscape0"), get_node("%Soundscape1")]
var soundscape_tween: Tween
var current_soundscape: int = 1
var temp_current_soundscape: int = 1

var music_stopped: bool = false

var chosen_player: AudioStreamPlayer
var tween: Tween

const music_path: String = "res://assets/sounds/music/"
const jingle_path: String = "res://assets/sounds/ui/"

func _ready() -> void:
	AudioServer.set_bus_volume_db(1, normalized_to_db(music_volume))
	SignalBus.connect("charlie_death", charlie_dies)

#region Needed functions
func tweeny(volumee: float, duration: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(chosen_player, "volume_db", normalized_to_db(volumee), duration)

func normalized_to_db(req_volume: float) -> float:
	return -60 * (1 - req_volume)
#endregion

#region Actual music functions
func play_music(music_file: String = "spy_a.ogg", player: int = 0, fade_in: float = 0) -> void:
	chosen_player = players[player]
	chosen_player.stream = null
	
	var music: Resource
	music = load("%s%s" % [music_path, music_file])
	chosen_player.stream = music
	
	if music_file.right(5) == ".tres":
		reset_stem_volume()
	
	music_stopped = false
	chosen_player.play()
	
	# this automatically jumps to 0 in 0 seconds when no values are input
	tweeny(1, fade_in)

func pause_music(player: int = 0, fade_out: float = 0) -> void:
	chosen_player = players[player]
	tweeny(0, fade_out)
	chosen_player.stream_paused = true

func resume_music(player: int = 0, fade_in: float = 0) -> void:
	chosen_player = players[player]
	chosen_player.stream_paused = false
	tweeny(1, fade_in)

func toggle_stem(index: int, stop: bool = false, fade: bool = true) -> void:
	var musicstems: AudioStreamSynchronized = chosen_player.stream
	if !stop:
		if musicstems.get_sync_stream_volume(index) != 0:
			if fade:
				# this is retarded lmao ????
				musicstems.set_sync_stream_volume(index, -60)
				await get_tree().create_timer(0.2).timeout
				musicstems.set_sync_stream_volume(index, -30)
				await get_tree().create_timer(0.2).timeout
				musicstems.set_sync_stream_volume(index, -15)
				await get_tree().create_timer(0.2).timeout
				musicstems.set_sync_stream_volume(index, -5)
				await get_tree().create_timer(0.2).timeout
				musicstems.set_sync_stream_volume(index, 0)
			else:
				musicstems.set_sync_stream_volume(index, 0)
		else:
			if fade:
				musicstems.set_sync_stream_volume(index, 0)
				await get_tree().create_timer(0.2).timeout
				musicstems.set_sync_stream_volume(index, -5)
				await get_tree().create_timer(0.2).timeout
				musicstems.set_sync_stream_volume(index, -15)
				await get_tree().create_timer(0.2).timeout
				musicstems.set_sync_stream_volume(index, -30)
				await get_tree().create_timer(0.2).timeout
				musicstems.set_sync_stream_volume(index, -60)
			else:
				musicstems.set_sync_stream_volume(index, -60)

# for whatever fucking reason, godot doesn't automatically reset the volume of the music stems
# so I had to write this function just to get around a really questionable decision (or oversight?)
func reset_stem_volume() -> void:
	# we minus it two because counting starts at 0 and we leave the first stream's vol alone
	var musicstems: AudioStreamSynchronized = chosen_player.stream
	var num: int = musicstems.stream_count - 1
	while num != 0:
		musicstems.set_sync_stream_volume(num, -60)
		num -= 1

func play_jingle(jingle_file: String) -> void:
	jingle.stream = load("%s%s" % [jingle_path, jingle_file])
	jingle.play()
	special_notif(0)

func play_end(_side: String = "A") -> void:
	# TODO replace with match side A B C to appro music
	secondary.stream = load("res://assets/sounds/ui/stage_clear.ogg")
	secondary.play()
	primary.stop()
	misc.stop()

func stop_music(fade_out: float = 0, player: int = 0) -> void:
	chosen_player = players[player]
	tweeny(0, fade_out)
	music_stopped = true

func volume(volumee: float = 1, time: float = 0, player: int = 0) -> void:
	chosen_player = players[player]
	tweeny(volumee, time)
#endregion

#region Jingle shit
func special_notif(mode: int = 0) -> void:
	chosen_player = primary
	match mode:
		0:
			primary.volume_db = normalized_to_db(0.8)
			secondary.volume_db = normalized_to_db(0.8)
		1:
			if !music_stopped:
				tween = create_tween().set_parallel(true)
				tween.set_trans(Tween.TRANS_SINE)
				tween.tween_property(primary, "volume_db", normalized_to_db(1), 1)
				tween.chain().tween_property(secondary, "volume_db", normalized_to_db(1), 1)

func _on_jingle_finished() -> void:
	special_notif(1)
#endregion

#region Music bus functions
func change_musicbus_volume(volumee: float) -> void:
	AudioServer.set_bus_volume_db(1, normalized_to_db(volumee))
#endregion

#region Upon Charlie death...
func charlie_dies() -> void:
	primary.stop()
	secondary.stop()
	misc.stop()
	jingle.stop()
	stop_soundscapes()
#endregion

#region Soundscape bullshittery
func play_soundscape(sound: Resource, fade_in: float = 0) -> void:
	if soundscape_tween: soundscape_tween.kill()
	soundscape_tween = create_tween() # ready tween
	
	temp_current_soundscape = current_soundscape
	temp_current_soundscape ^= 1
	soundscapes[temp_current_soundscape].stream = sound
	soundscapes[temp_current_soundscape].play()
	
	temp_current_soundscape ^= 1
	current_soundscape ^= 1
	
	soundscape_tween.tween_property(soundscapes[temp_current_soundscape], "volume_db", -80, fade_in * 2)\
	.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	soundscape_tween.set_parallel()
	soundscape_tween.tween_property(soundscapes[current_soundscape], "volume_db", 0, fade_in)\
	.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func return_current_soundscape() -> String:
	return soundscapes[current_soundscape].stream.resource_path

func stop_soundscapes(fade_out: float = 0) -> void:
	play_soundscape(load("res://assets/sounds/music/null.ogg"), fade_out) # cheap, eh?
#endregion
