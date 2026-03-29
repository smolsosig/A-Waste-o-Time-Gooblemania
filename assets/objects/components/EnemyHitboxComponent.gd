@icon("res://assets/misc/tools/icons/hitbox.png")
extends Area2D
class_name EnemyHitboxComponent

signal charlie_hurt

## Amount of damage to deal to Charlie.
@export var damage: int = 25
## The speed Charlie's health should drop, in HP per second (HP/s).
@export var damage_speed: float = 0.1
## You don't... need me to explain this to you, right?
@export var start_disabled: bool = false

func _ready() -> void:
	connect("area_entered", _on_area_entered)
	SignalBus.connect("reset", _reset)
	
	set_collision_layer(0)
	set_collision_mask(2)
	
	_reset()

func _reset() -> void:
	if start_disabled:
		set_deferred("monitoring", false)
	else:
		if !monitoring:
			set_deferred("monitoring", true)

func _on_area_entered(area: Area2D) -> void:
	if area is CharlieHurtboxComponent:
		area.damage(damage_speed, damage)
		emit_signal("charlie_hurt")

# Damage works by simply giving Charlie's health a new target to aim for. To use
# this, just change damage_speed and damage and hook this up to whatever thing
# that should prick Charlie's skin, be it enemies, spikes, etc.
#
# The decision to have damage add on if Charlie was already taking damage was
# made because if Charlie was hit first by a high-dmg dealing enemy and then was
# hit next by a low-dmg dealing enemy, the latter would cancel out the former's
# damage if all this thing did was just target_health = health - damage. This
# was kind of what happened in AWoT Attempt #1.
