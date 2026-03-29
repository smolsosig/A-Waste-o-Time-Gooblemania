@icon("res://assets/misc/tools/icons/health.png")
class_name gofuckingkillyourself extends Node
# Unlike Charlie's health component, which trickles down with a set speed and
# shit, enemy health decreases immediately. No rolling HP for you guys, sorry.

# this whole script and everything rel to enemies is a fucking mess

signal health_changed(health : int)
signal dead

## Duh.
@export var base_health: int = 50
@export_group("Hookables")
## AnimationPlayer. Requires "hurt" and "moving" anims.[br][br]Leave as blank if custom behavior is to be implemented.
@export var anim_player: AnimationPlayer
@export var hurt_comp: EnemyHurtboxComponent

@export_subgroup("Sound (optional)")
@export var hurt_sound: AudioStreamPlayer
@export var death_sound: AudioStreamPlayer

@export_group("Importants")
## If [code]true[/code], enemy will NOT respawn even after calling [code]SignalBus.emit_signal("reset")[/code].
@export var die_forever: bool = false
## If [code]true[/code], excludes itself from [code]Staglobals.ideal_kill[/code].
@export var exclude_from_enemy_count: bool = false
## Truth be told, I have no idea what the fuck this does.
@export var is_ground_enemy: bool = true
@export_enum("Light:1750", "Average:1400", "Heavy:1000", "Immovable:0") var weight_class : int = 1400

var died: bool = false

@onready var health: int = base_health:
	set(new_value):
		health = clampi(new_value, 0, base_health)
		
		if health != 0:
			emit_signal("health_changed", new_value)
		else:
			emit_signal("dead")
			die() # temporary func

func _ready() -> void:
	assert(hurt_comp, "%s: Missing EnemyHitboxComponent." % name)
	SignalBus.connect("reset", _reset)
	if anim_player:
		anim_player.connect("animation_finished", anim_finish)

func damage(damagee : int) -> void:
	hurt_comp.set_deferred("monitoring", false)
	health -= damagee
	
	if health > 0 && hurt_sound:
		hurt_sound.play()
	
	if anim_player:
		anim_player.play("hurt")
	
	if is_ground_enemy && weight_class:
		get_parent().velocity.y = weight_class * -1

func die() -> void:
	# TODO replace with die anim
	hurt_comp.set_deferred("monitoring", false)
	if !exclude_from_enemy_count:
		Staglobals.actual_kill += 1
	if death_sound:
		death_sound.play()
		await death_sound.finished
	died = true

func anim_finish(anim_name : String) -> void:
	if anim_name == "hurt":
		hurt_comp.set_deferred("monitoring", true)
		anim_player.play("moving")
		
		if is_ground_enemy:
			get_parent().swap()

func _reset() -> void:
	health = base_health
	if died:
		hurt_comp.set_deferred("monitoring", true)
		hurt_comp.get_child(0).set_deferred("disabled", false)
		Staglobals.actual_kill -= 1
		died = false
