@tool
@icon("res://assets/misc/tools/icons/CharlieTeleporter.png")
class_name CharlieTeleporter extends CharlieTrigger
## [CharlieTrigger] that teleports Charlie to a specified [CharlieSpawner].

## The [CharlieSpawner] to teleport to.
@export var tele_target: CharlieSpawner
## If [code]true[/code], the camera instantly moves to Charlie's location.
@export var instant_camera: bool = false
## 
@export var carry_velocity: bool = false

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	
	repeatable = true

func _on_area_entered(area: Area2D) -> void:
	super(area)
	tele_target.teleport(false, carry_velocity)
	if instant_camera: SignalBus.emit_signal("stop_fucking_moving_so_slowly_damn")
