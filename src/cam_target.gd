class_name CameraTarget extends Marker2D
## Fancy [Marker2D] meant to be used in conjunction with a [CameraRegionController2D].

## If [code]true[/code], the [CameraTarget] will follow either Charlie or
## the specified [member override_target].
@export var follow_anything: bool = true
## reference to charlie awot from a waste o time!!!
@export var charlie: CharacterBody2D
## You gotta be shitting me if you need this explained.
@export var offset: Vector2 = Vector2.ZERO
## The new target this [CameraTarget] will follow.
@export var override_target: Node2D
@export_category("Lookahead")
## If [code]true[/code], camera looks ahead of Charlie.
@export var lookahead: bool = true
## How much should the camera look ahead of Charlie.
@export var lookahead_offset: float = 250
## Yeah.
@export var lerp_weight: float = 10

var _combined_position: Vector2
var _charlie_height_offset: float = 150.0

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
		
			if Input.is_action_pressed("player_left") || Input.is_action_pressed("player_right"):
				if Input.is_action_pressed("player_left"):
					offset.x = lerp(offset.x, -lookahead_offset, lerp_weight * delta)
				elif Input.is_action_pressed("player_right"):
					offset.x = lerp(offset.x, lookahead_offset, lerp_weight * delta)
			else:
				offset.x = lerp(offset.x, 0.0, lerp_weight * 0.25 * delta)
		
		else:
			global_position = override_target.global_position + offset
