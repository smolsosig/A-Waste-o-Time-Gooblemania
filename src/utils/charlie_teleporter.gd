@tool
@icon("res://assets/misc/tools/icons/CharlieTeleporter.png")
class_name CharlieTeleporter extends CharlieTrigger
## Teleports Charlie to a specified [code]CharlieTeleporter[/code].

@export var tele_target: CharlieSpawner

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	
	repeatable = true
	
	var output: Output = Output.new()
	output.output = "area_entered"
	output.target = tele_target.get_path()
	output.target_method = "teleport"
	
	on_enter_outputs.append(output)
