@icon("res://assets/misc/tools/icons/GameTimer.png")
class_name GameTimer extends Timer
## Timer that resets when Charlie herself resets.

var _is_create_timer_substitute: bool

func _ready() -> void:
	SignalBus.connect("charlie_death", death)
	SignalBus.connect("reset", reset)
	SignalBus.connect("stage_end", death)
	
	if _is_create_timer_substitute:
		autostart = true
		one_shot = true
		timeout.connect(queue_free)

func death() -> void:
	stop()

func reset() -> void:
	if autostart:
		start()
