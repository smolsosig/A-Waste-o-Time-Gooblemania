@icon("res://assets/misc/tools/icons/GameTimer.png")
class_name GameTimer extends Timer
## Timer that resets when Charlie herself resets.

func _ready() -> void:
	SignalBus.connect("charlie_death", death)
	SignalBus.connect("reset", reset)
	SignalBus.connect("stage_end", death)

func death() -> void:
	stop()

func reset() -> void:
	if autostart:
		start()
