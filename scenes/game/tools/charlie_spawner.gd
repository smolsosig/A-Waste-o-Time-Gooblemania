@tool
@icon("res://assets/misc/tools/icons/CharlieSpawner.png")
class_name CharlieSpawner extends Node2D
## Marker to spawn/teleport Charlie on. It teleports Charlie to its [code]global_position[/code].
##
## [b]DO NOT ADD BY ITSELF!!![/b] Use the [code]charlie_spawner.tscn[/code] scene found in
## [code]res://scenes/game/tools/charlie_spawner.tscn[/code].[br][br]
## Often used in conjunction with [CharlieTeleporter]s.

# START SPAWN = 0. SUBSEQUENT CHECKPOINTS = DIFFERENT NUMBERS
# IF USED AS TELEPORT MARKER, LEAVE DEFAULT 999 VALUE

## [b]Priority # of this [CharlieSpawner].[/b][br][br]
## Set to [code]0[/code] if starting spawn, then [code]1[/code], [code]2[/code] and onwards for checkpoints.[br]
## For use as a destination marker for [CharlieTeleporter]s, leave as default value ([code]999[/code]).
## [br][br]Ensure each [CharlieSpawner] has a unique ID! Otherwise, Charlie will spawn on the
## [CharlieSpawner] nearest the bottom of the scene tree.
@export var spawn_num_id: int = 999:
	set(new_value):
		clampi(new_value, 0, 999)
		get_node('%NumLabel').text = str(new_value) if new_value < 999 else ""
		spawn_num_id = new_value

## The animation Charlie should play when spawning via this spawner.
@export var custom_anim_name: String = "null"
## If [code]false[/code], hides the HUD when spawning.
@export var show_hud: bool = true
## If [code]true[/code], forces Charlie to walk after the opening anim.
@export var only_walk: bool = false
## When you spawn here, shows the obi 2.5 seconds later. Only recommended for the first spawn.
## You don't really need to be reminded what level you're in when you spawn on a checkpoint.
@export var show_obi: bool = false

var _spritey: Sprite2D

func _ready() -> void:
	if !get_children():
		push_error("%s: Do you not fucking read what THE DOCUMENTATION SAYS DAWG" % name)
		return
		
	_spritey = $Sprite2D
	if Engine.is_editor_hint():
		_spritey.visible = true
	else:
		_spritey.visible = false
	
	SignalBus.connect("reset", tele_spawn)
	tele_spawn()

## Teleports Charlie to itself, then deploys proprietary smoke and mirrors (hacked-together bullshit)
## to pretend like you spawned there.
func tele_spawn() -> void:
	if !Engine.is_editor_hint():
		if Staglobals.current_spawn == spawn_num_id:
			Staglobals.current_spawn_anim = custom_anim_name
			# brief allowance fixes weird ass bug
			# also gives LevelInit time to setup debug charlie spawn (if any)
			await get_tree().create_timer(0.05).timeout
			
			teleport(true)
			
			if show_hud && Staglobals.hud_hidden:
				Staglobals.emit_signal("show_hud")
			elif !show_hud && !Staglobals.hud_hidden:
				Staglobals.emit_signal("show_hud", false)
			
			SignalBus.emit_signal("charlie_walk", only_walk)
			Staglobals.freeze_frame_on_hurt = true

## Teleports Charlie to itself with no extra bullshittery.
func teleport(spawn: bool = false, carry_velocity: bool = false) -> void:
	var new_pos_y: float
	# Charlie falls through platforms if I don't give her much foot room????
	new_pos_y = global_position.y - 25 if spawn else global_position.y - 1
	
	SignalBus.emit_signal("charlie_change_pos", Vector2i(global_position.x, new_pos_y), spawn, carry_velocity)
	
	if spawn && show_obi:
		await get_tree().create_timer(2.5).timeout
		SignalBus.emit_signal("show_obi")
