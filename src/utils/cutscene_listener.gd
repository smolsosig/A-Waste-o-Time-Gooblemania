@icon("res://assets/misc/tools/icons/eventlistener.png")
class_name CutsceneEndListener extends Node

## The name of the cutscene to listen for.
@export var cutscene_name: String

signal cutscene_finished

func _ready() -> void:
	SignalBus.connect("charlie_cutscene_finished", do_shit)

func do_shit(action: String) -> void:
	if action == cutscene_name:
		emit_signal("cutscene_finished")
