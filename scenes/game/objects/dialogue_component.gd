@icon("res://assets/misc/tools/icons/DialogueComponent.png")
class_name DialogueComponent extends Node
## Component that handles what dialogue to show.
##
## This is best paired with an [InteractableComponent], but anything that calls this Node's
## [code]interacted()[/code] method will do.

## The key in the stage's _dialog.gd file that the dialogue UI will show.
@export var key: String = ""
## Set to [code]true[/code] if the thing is meant to say something else after talking to it once.
## Otherwise, setting it to [code]false[/code] simply shows the same dialogue forever when talking to it.
@export var afterloop: bool = false

var is_talked: bool = false

func _ready() -> void:
	SignalBus.connect("reset", reset)
	reset()

func reset() -> void:
	if is_talked:
		is_talked = false

func interacted() -> void:
	if !key: print("%s sez: I have no dialogue key. Means I can't do anything!")
	
	SignalBus.emit_signal("charlie_cutscene", "idle", "", false)
	
	if !afterloop:
		SignalBus.emit_signal("dialogue_display", key)
	else:
		# checks if you've talked to it before
		if !is_talked:
			SignalBus.emit_signal("dialogue_display", key)
			is_talked = true
		else:
			SignalBus.emit_signal("dialogue_display", "%s_loop" % key)
