@tool
@icon("res://assets/misc/tools/icons/CharlieGearToggler.png")
class_name CharlieGearToggler extends CharlieTrigger
## Allows toggling Charlie's gear on or off at specific points in the level.
##
## Make sure the stuff you're enabling is also enabled in the level's [LevelInit]!

## If [code]false[/code], turns off switching weapons.
@export var switch_weapons: bool = true
## If [code]false[/code], turns off using the bat.
@export var melee: bool = true
## If [code]false[/code], turns off using the throwing stars.
@export var ranged: bool = true
## If [code]false[/code], turns off double jumping.
@export var double_jump: bool = true
## If [code]false[/code], turns off dashing.
@export var dash: bool = true
## If [code]false[/code], turns off using crystal abilities.
@export var crystals: bool = true
## If [code]false[/code], turns off using Wibbie Goddess' Blessing.
@export var blessing: bool = true

func _on_area_entered(area: Area2D) -> void:
	super(area)
	if Engine.is_editor_hint():
		return
	
	PlayerVar.can_switch_weapon = switch_weapons

	if melee && !ranged || !melee && !ranged:
		if !PlayerVar.melee: PlayerVar.melee = true
	elif !melee && range:
		if PlayerVar.melee: PlayerVar.melee = false
	
	if !melee && !ranged:
		if PlayerVar.can_use_weapons: PlayerVar.can_use_weapons = false
	else:
		if !PlayerVar.can_use_weapons: PlayerVar.can_use_weapons = true
		
	PlayerVar.double_jump = double_jump
	PlayerVar.dash = dash
	PlayerVar.crystalcrown = crystals
	PlayerVar.wibbie_blessing = blessing
