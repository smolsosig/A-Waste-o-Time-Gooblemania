@icon("res://assets/misc/tools/icons/hurtbox.png")
class_name EnemyHurtboxComponent extends Area2D
## Hurtboxes for enemies, or pretty much anything that Charlie can hit and deal damage to.
##
## Requires [code]damage_num.tscn[/code] and [code]crit_fx.tscn[/code] to function at all!

signal hit(damage: int)

## The type of damage that Charlie can deal to the enemy.[br]
## This can be changed at runtime, so an enemy could, for instance, start with
## both damage types allowed, and later can only be dealt damage with melee weapons.[br][br]
## [b]Both:[/b] Both melee and ranged weapons deal damage.[br][br]
## [b]Melee:[/b] Only Charlie's melee weapons (bats) can deal damage.[br][br]
## [b]Ranged:[/b] Only Charlie's ranged weapons (throwing stars) can deal damage.[br][br]
## [b]None:[/b] Nothing Charlie could do can deal damage. Not even lovebombing.
@export_enum("Both", "Melee", "Ranged", "None") var damage_allowed: int
## Set how powerful/weak melee damage can be. Useful if you don't want to ban damage types outright, or if you want a certain attack buffed.
@export_range(0, 2, 0.05) var melee_damage_multiplier: float = 1.0
## Set how powerful/weak ranged damage can be. Useful if you don't want to ban damage types outright, or if you want a certain attack buffed.
@export_range(0, 2, 0.05) var ranged_damage_multiplier: float = 1.0
## If [code]true[/code], Charlie can bounce off the enemy if she attacks it in mid-air.
@export var can_bounce_off_it: bool = false
## You don't... need me to explain this to you, right?
@export var start_disabled: bool = false
## When [code]true[/code], flashes the parent node white when damaged.
@export var flash_white_when_damaged: bool = false

@export_group("Eye for an Eye")
## If [code]true[/code], gives Charlie health on hit.
@export var health_on_hit: bool = false
## Amount of health to give Charlie.
@export var health_given: int = 20
## How fast Charlie's health increases.
@export var health_speed: float = 0.1
## Disables [health_on_hit] after Charlie hits the hurtbox.
@export var disable_after_hit: bool = true
## How much extra damage to multiply when Charlie hits the hurtbox if [health_on_hit] is [code]true[/code].[br][br]
## Thanks for the health, asshole!
@export_range(1, 2, 0.05) var multiply_damage_on_hit: float = 1.25

@export_group("References")
## The [EnemyHealthComponent] to check.
@export var health_component: EnemyHealthComponent
## Requires [code]crit_fx.tscn[/code].
@export var crit_fx: Node2D
## Requires [code]damage_num.tscn[/code].
@export var damage_num: Node2D

@onready var flash_shader: Shader = load("res://assets/effects/shaders/flash.gdshader") if flash_white_when_damaged else null

var _ohshit: AudioStreamOggVorbis = load("res://assets/sounds/ui/enemy_majorhit.ogg")

func _ready() -> void:
	SignalBus.connect("crit_delivered", set_crit)
	SignalBus.connect("reset", _reset)
	
	assert(health_component, "%s: EnemyHealthComponent not found. I will not function properly!" % name)
	assert(damage_num, "%s: DamageNum not found. I will not function correctly!" % name)
	assert(crit_fx, "%s: CritFX not found. I will not function correctly!" % name)
	
	set_collision_layer_value(1, false)
	set_collision_layer_value(3, true)
	set_collision_mask_value(1, false)
	
	if flash_white_when_damaged && !material:
		var new_material: ShaderMaterial = ShaderMaterial.new()
		new_material.shader = flash_shader
		get_parent().material = new_material
	
	_reset()

func _reset() -> void:
	if start_disabled:
		set_deferred("monitorable", false)
	else:
		if !monitorable:
			set_deferred("monitorable", true)

func set_crit(supercrit: bool) -> void:
	crit_fx.supercrit = supercrit

# damage
func damage(type: int, dmg: int, crit: bool = false) -> void:
	if type == damage_allowed || !damage_allowed:
		if crit:
			damage_num.is_crit = true
			crit_fx.play_anim()
		
		var damage_multiplier: float
		if type == 1: damage_multiplier = melee_damage_multiplier
		elif type == 2: damage_multiplier = ranged_damage_multiplier
		
		health_component.health -= dmg * damage_multiplier * (multiply_damage_on_hit if health_on_hit else 1.0)
		damage_num.play_anim(dmg * damage_multiplier)
		emit_signal("hit", dmg)
		
		if flash_white_when_damaged:
			var parent: Node2D = get_parent()
			parent.material.set_shader_parameter("active", true)
			await get_tree().create_timer(0.05).timeout
			parent.material.set_shader_parameter("active", false)
	
	if health_on_hit:
		give_health_on_hit()
	
func give_health_on_hit() -> void:
	SoundManager.play_ui_sound(_ohshit)
	PlayerVar.target_health = PlayerVar.health + health_given
	PlayerVar.health_speed = health_speed
	if disable_after_hit: health_on_hit = false
