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

@onready var charlie: CharacterBody2D = $"../Charlie"

var thing: float = 1

func _ready() -> void:
	SignalBus.connect("reset", _reset)

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
			if offset.y != -_charlie_height_offset: offset.y = -_charlie_height_offset
			
			_combined_position = charlie.global_position + offset
			global_position = _combined_position
		
			thing = 1.0 if !offset.x else 0.25
			
			if Input.is_action_pressed("player_left") || Input.is_action_pressed("player_right"):
				if Input.is_action_pressed("player_left"):
					offset.x = lerp(offset.x, -lookahead_offset, lerp_weight * delta * thing)
				elif Input.is_action_pressed("player_right"):
					offset.x = lerp(offset.x, lookahead_offset, lerp_weight * delta * thing)
			else:
				offset.x = lerp(offset.x, 0.0, lerp_weight * 0.1 * delta)
		
		else:
			global_position = override_target.global_position + offset

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_b") && follow_anything:
		follow_anything = false
		await get_tree().create_timer(0.125).timeout
		offset.x = 0
		follow_anything = true
