@icon("res://assets/misc/tools/icons/GameAudioStreamPlayer2D.png")
extends AudioStreamPlayer2D
class_name GameAudioStreamPlayer2D
## AudioStreamPlayer2D that resets when Charlie herself resets.

## If [code]true[/code], stops the sound if Charlie dies.
@export var stop_if_die: bool = true
## If [code]true[/code], grabs the stream's length and starts at a random time if it's set to autoplay.
@export var autoplay_at_random_time: bool = false

func _ready() -> void:
	SignalBus.connect("charlie_death", death)
	SignalBus.connect("reset", reset)
	SignalBus.connect("stage_end", death)
	
	reset()

func death() -> void:
	if stop_if_die:
		stop()

func reset() -> void:
	if autoplay:
		if !autoplay_at_random_time: play()
		else:
			play(randf_range(0, stream.get_length()))
