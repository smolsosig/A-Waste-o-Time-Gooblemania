@icon("res://assets/misc/tools/icons/GameAudioStreamPlayer2D.png")
extends AudioStreamPlayer2D
class_name GameAudioStreamPlayer2D
## AudioStreamPlayer2D that resets when Charlie herself resets.

## If [code]true[/code], stops the sound if Charlie dies.
@export var stop_if_die: bool = true
## If [code]true[/code], grabs the stream's length and starts at a random time if it's set to autoplay.
@export var autoplay_at_random_time: bool = false

@export_group("Bandaid Solutions To Bullshit Problems")
@export var loop_audio: bool = false
@export var loop_audio_offset: float = 0.0

func _ready() -> void:
	SignalBus.connect("charlie_death", death)
	SignalBus.connect("reset", reset)
	SignalBus.connect("stage_end", death)
	connect("finished", _finished)
	
	reset()

func death() -> void:
	if stop_if_die:
		stop()

func reset() -> void:
	if autoplay:
		if !autoplay_at_random_time: play()
		else:
			play(randf_range(0, stream.get_length()))

func _finished() -> void:
	if loop_audio:
		play(loop_audio_offset)
