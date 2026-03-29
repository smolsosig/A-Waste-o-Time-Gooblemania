@icon("res://assets/misc/tools/icons/stageend.png")
class_name StageEnd extends Node
## Ends the level.
##
## Really needed a whole node to call [code]SignalBus.emit_signal("stage_end")[/code], huh?

func end() -> void:
	SignalBus.emit_signal("stage_end")
