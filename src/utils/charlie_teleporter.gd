@tool
@icon("res://assets/misc/tools/icons/CharlieTeleporter.png")
class_name CharlieTeleporter extends CharlieTrigger
## [CharlieTrigger] that teleports Charlie to a specified [CharlieSpawn].

@export var tele_target: CharlieSpawner

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	
	repeatable = true

func _on_area_entered(area: Area2D) -> void:
	super(area)
	tele_target.teleport()
