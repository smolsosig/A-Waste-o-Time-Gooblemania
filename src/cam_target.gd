class_name CameraTarget extends Marker2D
## Fancy [Marker2D] meant to be used in conjunction with a [CameraRegionController2D].
##
## Requires Charlie to be a sibling in the scene tree!

## If [code]true[/code], the [CameraTarget] will follow either Charlie or
## the specified [member override_target].
@export var follow_anything: bool = true
## You gotta be shitting me if you need this explained.
@export var offset: Vector2 = Vector2.ZERO
## The new target this [CameraTarget] will follow.
@export var override_target: Node2D
@export_category("Lookahead")
## If [code]true[/code], camera looks ahead of Charlie.
@export var lookahead: bool = true
## How much should the camera look ahead of Charlie.
@export var lookahead_offset: float = 150
## Yeah.
@export var lerp_weight: float = 10

var _combined_position: Vector2
var _charlie_height_offset: float = 150.0
@onready var _charlie_offset: Vector2 = Vector2(0, -_charlie_height_offset)

@onready var charlie: CharacterBody2D = $"../Charlie"
var move: bool = true
var thing: float = 1

func _ready() -> void:
	SignalBus.connect("reset", _reset)
	SignalBus.connect("charlie_cutscene", cutscene)
	SignalBus.connect("charlie_cutscene_finished", cutscene_end)
	SignalBus.connect("charlie_cutscene_stop", cutscene_end)

# we turn off Charlie getting hurt in cutscenes as to prevent any bugs
func cutscene(_a: String, _b: String, _c: bool) -> void:
	move = false

# then we let her back in the wild as soon as the cutscene finishes
func cutscene_end(_a: String = "SHUT THE FUCK UP") -> void:
	move = true

func _reset() -> void:
	follow_anything = true
	override_target = null
	offset = Vector2.ZERO

## Sets a new target for the [CameraTarget] to follow.
## Calling the method by itself simply resets the target back to Charlie.
func set_new_target(new_target: Node2D = null, new_offset: Vector2 = Vector2.ZERO) -> void:
	override_target = new_target
	offset = new_offset

func _process(delta: float) -> void:
	if follow_anything:
		if !override_target:
			thing = 1.0 if !offset.x else 0.25
			
			if move:
				if Input.is_action_pressed("player_left") || Input.is_action_pressed("player_right"):
					if Input.is_action_pressed("player_left"):
						_charlie_offset.x = lerp(offset.x, -lookahead_offset, lerp_weight * delta * thing)
					elif Input.is_action_pressed("player_right"):
						_charlie_offset.x = lerp(offset.x, lookahead_offset, lerp_weight * delta * thing)
				else:
					_charlie_offset.x = lerp(offset.x, 0.0, lerp_weight * 0.1 * delta)
			
			_combined_position = charlie.global_position + offset + _charlie_offset
			global_position = _combined_position
		
		else:
			global_position = override_target.global_position + offset

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_b") && follow_anything:
		follow_anything = false
		await get_tree().create_timer(0.125).timeout
		offset.x = 0
		follow_anything = true
