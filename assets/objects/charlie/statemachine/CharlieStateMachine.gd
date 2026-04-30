@icon("res://assets/misc/tools/icons/CharlieState.png")
class_name CharlieStateMachine extends Node

@export var charlie: CharacterBody2D
@export var current_state: CharlieState
@export var last_state: CharlieState

@export_category("Debug")
## Shows [code]current_state[/code] and [code]last_state[/code].
@export var show_state_in_output: bool = false

var states: Array[CharlieState]

func _ready() -> void:
	SignalBus.connect("reset", _reset)
	for child in get_children():
		if(child is CharlieState):
			states.append(child)
			
			# light em up
			child.charlie = charlie
			
			# excuseeeee me princess
			child.connect("interrupt_state", on_state_interrupt_state)
			
		else:
			push_warning("What's \"%s?\" What the fuck is that state?" % child.name)
	
	switch_states(get_node("InitState"))

func _physics_process(delta: float) -> void:
	if(current_state.next_state != null):
		switch_states(current_state.next_state)
	
	current_state.state_process(delta)

func check_if_can_move() -> bool:
	return current_state.can_move

func check_can_change_direction() -> bool:
	return true if current_state.can_move else current_state.can_change_direction

func switch_states(new_state: CharlieState) -> void:
	if(current_state != null):
		current_state.on_exit()
		current_state.next_state = null
	
	last_state = current_state
	current_state = new_state
	if show_state_in_output:
		print("Current state: %s | Last state: %s" % [current_state, last_state])
	
	current_state.on_enter()
	charlie.can_move = current_state.can_move

func _reset() -> void:
	switch_states(get_node("InitState"))

func _input(event: InputEvent) -> void:
	current_state.state_input(event)

func on_state_interrupt_state(new_state: CharlieState) -> void:
	switch_states(new_state)
