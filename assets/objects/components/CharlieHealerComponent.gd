@tool
@icon("res://assets/misc/tools/icons/CharlieHealerComponent.png")
class_name CharlieHealerComponent extends CharlieTrigger

## Amount of health to give Charlie.
@export var health: int = 25
## The speed Charlie's health should increase, in HP per second (HP/s).
@export var health_speed: float = 0.1

func _on_area_entered(area: Area2D) -> void:
	super(area)
	if Engine.is_editor_hint():
		return
	
	if area is CharlieHurtboxComponent:
		PlayerVar.target_health = PlayerVar.health + health
		PlayerVar.health_speed = health_speed
