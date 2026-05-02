@icon("res://assets/misc/tools/icons/eventlistener.png")
class_name DialogueListener extends Node
## Listens to the current dialogue and emits signals based on the currently shown dialogue.
##
## When a certain line is shown, emits a signal. Allows listening for up to eight lines.

#region signals
signal dialogue_1_shown
signal dialogue_2_shown
signal dialogue_3_shown
signal dialogue_4_shown
signal dialogue_5_shown
signal dialogue_6_shown
signal dialogue_7_shown
signal dialogue_8_shown
signal dialogues_1_shown
signal dialogues_2_shown
signal dialogues_3_shown
signal dialogues_4_shown
#endregion

#region dialogue vars
@export_category("Individual Dialogues")
@export var listen_for_dialogue_1: String
@export var listen_for_dialogue_2: String
@export var listen_for_dialogue_3: String
@export var listen_for_dialogue_4: String
@export var listen_for_dialogue_5: String
@export var listen_for_dialogue_6: String
@export var listen_for_dialogue_7: String
@export var listen_for_dialogue_8: String

@export_category("Group Dialogues")
@export var listen_for_dialogues_1: Array[String]
@export var listen_for_dialogues_2: Array[String]
@export var listen_for_dialogues_3: Array[String]
@export var listen_for_dialogues_4: Array[String]
#endregion

func _ready() -> void:
	Staglobals.connect("dialogue_progression", _listen)

func _listen(key: String) -> void:
	match key:
		listen_for_dialogue_1: dialogue_1_shown.emit()
		listen_for_dialogue_2: dialogue_2_shown.emit()
		listen_for_dialogue_3: dialogue_3_shown.emit()
		listen_for_dialogue_4: dialogue_4_shown.emit()
		listen_for_dialogue_5: dialogue_5_shown.emit()
		listen_for_dialogue_6: dialogue_6_shown.emit()
		listen_for_dialogue_7: dialogue_7_shown.emit()
		listen_for_dialogue_8: dialogue_8_shown.emit()
		_:
			if key in listen_for_dialogues_1: dialogues_1_shown.emit()
			if key in listen_for_dialogues_2: dialogues_2_shown.emit()
			if key in listen_for_dialogues_3: dialogues_3_shown.emit()
			if key in listen_for_dialogues_4: dialogues_4_shown.emit()
