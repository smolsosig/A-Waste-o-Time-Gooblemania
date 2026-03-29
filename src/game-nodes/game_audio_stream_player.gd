@icon("res://assets/misc/tools/icons/GameAudioStreamPlayer.png")
class_name GameAudioStreamPlayer extends AudioStreamPlayer
## AudioStreamPlayer that resets when Charlie herself resets.

## If [code]true[/code], stops the sound if Charlie dies.
@export var stop_if_die: bool = true
## If [code]true[/code], grabs the stream's length and starts at a random time if it's set to autoplay.
@export var autoplay_at_random_time: bool = false

var last_volume_db: float
var tween: Tween

func _ready() -> void:
	SignalBus.connect("charlie_death", death)
	SignalBus.connect("reset", reset)
	SignalBus.connect("stage_end", death)
	
	reset()

## Plays a sound from the beginning, or the given [code]from_position[/code] in seconds, while
## fading the sound in in seconds.
func play_with_fade(fade_in: float = 0, from_position: float = 0) -> void:
	play(from_position)
	last_volume_db = volume_db
	volume_db = -80.0
	tween = create_tween()
	tween.tween_property(self, "volume_db", last_volume_db, fade_in).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func stop_with_fade(fade_out: float = 0) -> void:
	tween = create_tween()
	tween.tween_property(self, "volume_db", -80, fade_out).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	await tween.finished
	stop()

func death() -> void:
	if stop_if_die:
		stop()
	if tween:
		tween.kill()

func reset() -> void:
	stop()
	if autoplay && !playing:
		if !autoplay_at_random_time: play()
		else:
			play(randf_range(0, stream.get_length()))
