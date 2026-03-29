@icon("res://assets/misc/tools/icons/health.png")
class_name EnemyHealthComponent extends Node

## Emitted every time [code]health[/code] is changed.
signal health_changed(current_health: int, decrease: bool)
## Emitted when [code]health[/code] is zero.[br]
## Recommended over checking the [code]health_changed[/code] signal if it returns zero.
signal died

## How much health the enemy initially has.
@export var base_health: int = 50
## If [code]true[/code], enemy will NOT respawn even after calling [code]SignalBus.emit_signal("reset")[/code].
@export var die_forever: bool = false
## If [code]true[/code], excludes itself from [code]Staglobals.ideal_kill[/code].
@export var exclude_from_enemy_count: bool = false

var health: int:
	set(value):
		if value > 0:
			var decrease: bool
			if value > health: decrease = false
			else: decrease = true
			
			emit_signal("health_changed", value, decrease)
		else:
			_dead()
		health = value
var is_dead: bool = false

func _ready() -> void:
	SignalBus.connect("reset", _reset)
	health = base_health

func _reset() -> void:
	if die_forever:
		if !is_dead:
			health = base_health
			is_dead = false
	else:
		health = base_health
		is_dead = false

func _dead() -> void:
	is_dead = true
	emit_signal("died")
	if !exclude_from_enemy_count:
		Staglobals.actual_kill += 1
