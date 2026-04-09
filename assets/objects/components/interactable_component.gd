@tool
@icon("res://assets/misc/tools/icons/InteractableComponent.png")
class_name InteractableComponent extends CharlieTrigger
## [CharlieTrigger] that allows Charlie to interact with something by way of pressing W.
##
## [b]DO NOT ADD BY ITSELF!!![/b] Use the [code]interactable_component.tscn[/code] scene found in
## [code]res://assets/objects/components/interactable_component.tscn[/code].

## Emitted when the [InteractableComponent] is, erh, interacted with.
signal interacted
## Emitted when the [InteractableComponent] is interacted with again and [code]unique_first_interaction[/code] is on.
signal interacted_again
## What the [code]object_prompt[/code] displays. E.g. [code]"Interact"[/code], [code]"Enter"[/code], [code]"Talk"[/code].
## It is automatically converted to uppercase, so [code]"Shut Charlie up"[/code] and [code]"SHUT CHARLIE UP"[/code] will display the same.
@export var text_prompt: String = "Interact"
## Purely cosmetic variable. If [code]false[/code], displays the dialogue speech bubble.
## Set to [code]true[/code] if meant for other actions, such as going inside a door.
@export var is_action: bool = true
## The action that the player must press to interact with the [InteractableComponent]. Granted, I'm not sure why you'd change this.
@export var action_name: StringName = &"player_up"
## If [code]true[/code], allows a unique first interaction. Useful for dialogue.
@export var unique_first_interaction: bool = false
## If [code]true[/code], only allows a single interaction.[br][br]
## Use in lieu of setting [code]repeatable[/code] to [code]false[/code], as a stage might need the [InteractableComponent] to be triggered only once.
@export var only_one_interaction: bool = false
@onready var _object_prompt: Node2D = get_node("ObjectPrompt")

var _is_charlie_in: bool = false
var _was_triggered: bool = false

var _interacted_outputs: Array
var _interacted_again_outputs: Array

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	
	_object_prompt.action_name = action_name
	
	if !_object_prompt:
		push_error("Missing object prompt. You do not listen. I will not work. Bye!")
		return
	
	repeatable = true
	
	for _output: Output in outputs:
		if _output.output == "interacted":
			_interacted_outputs.append(_output)
		elif _output.output == "interacted_again":
			_interacted_again_outputs.append(_output)

func _on_area_entered(area: Area2D) -> void:
	super(area)
	if area is CharlieDetectableComponent:
		_object_prompt.appear(text_prompt, is_action)
		_is_charlie_in = true

func _on_area_exited(area: Area2D) -> void:
	super(area)
	if area is CharlieDetectableComponent:
		_object_prompt.disappear()
		_is_charlie_in = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(action_name) && _is_charlie_in:
		if !unique_first_interaction:
			_do_shit_int()
			_emit_outputs(_interacted_outputs)
			emit_signal("interacted")
		else:
			if !_was_triggered:
				_do_shit_int()
				_emit_outputs(_interacted_outputs)
				emit_signal("interacted")
				_was_triggered = true
			else: 
				_do_shit_int_triggered()
				_emit_outputs(_interacted_again_outputs)
				emit_signal("interacted_again")
		
		if only_one_interaction:
			set_deferred("monitoring", false)

# in the occasion that Charlie dies in the middle of going in a portal
func _reset() -> void:
	super()
	set_deferred("monitoring", enable_on_start)
	if unique_first_interaction && _was_triggered:
		_was_triggered = false

# extra functionality when script is extended, similar to CharlieTrigger
func _do_shit_int() -> void:
	pass

func _do_shit_int_triggered() -> void:
	pass

# these simply turn off/on the monitoring thing so that Charlie
# doesn't once again edge the damn thing
