class_name SequenceManager extends Node
## Simple sequence. I have no idea how to describe this.

signal sequence_finished

## The name of the event this fires off.
@export var event_name: String
## Internal counter.
@export var required_num: int = 0
## If [code]true[/code], resets [code]count[/code] to zero.
@export var reset_on_death: bool = true
var count: int = 0:
	set(value):
		clamp(value, 0, count)
		if value == required_num:
			_sequence_finished()
		count = value

func _ready() -> void:
	SignalBus.connect("reset", _reset)

func _reset() -> void:
	if reset_on_death:
		count = 0

func _sequence_finished() -> void:
	emit_signal("sequence_finished")
	SignalBus.emit_signal("event_finished", event_name)
	await get_tree().create_timer(0.2).timeout
	MusicManager.play_jingle("sequence_complete.ogg")
