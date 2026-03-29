@icon("res://assets/misc/tools/icons/CharlieState.png")
class_name CharlieState extends Node

## If [code]true[/code], allows Charlie to move when in this state.
@export var can_move: bool = true
## Only used if [code]can_move[/code] is [code]false[/code].[br]
## If [code]true[/code], allows Charlie to change her direction when player presses [code]player_left[/code] or [code]player_right[/code].
@export var can_change_direction: bool = false

var charlie : CharacterBody2D
var next_state :  CharlieState
var current_state : CharlieState

@onready var anim_player : AnimationPlayer = %AnimationPlayer
@onready var sprite : AnimatedSprite2D = %CharlieSprite
@onready var current_anim : String = anim_player.get_current_animation()

signal interrupt_state(new_state : CharlieState)

func state_process(_delta : float) -> void:
	pass

func state_input(_event : InputEvent) -> void:
	pass

func on_enter() -> void:
	pass

func on_exit() -> void:
	pass
