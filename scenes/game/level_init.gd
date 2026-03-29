@icon("res://assets/misc/tools/icons/LevelInit.png")
class_name LevelInit extends Node2D
## Node that defines stage details, allowed gear, etc.

## The stage's name. Do NOT put "Side A/B/C" anywhere here.
@export var stage_name: String = "null"
## Is this stage part of a bigger level? Set to [code]A[/code], [code]B[/code], or [code]C[/code] if true.
## Set to [code]sideless[/code] if it's not a main level.
@export_enum("sideless", "A", "B", "C") var side: String = "sideless"

## If [code]true[/code], plays a zoom-out sound every time the level starts.
@export var play_sound_on_start: bool = true

## The texture of the stage's obi strip, used for its titlecard.
@export var obi_texture: Texture2D

@export_group("Stats Recording")
## If [code]true[/code], allows recording of time, Wiblings collected, kills, deaths and secrets.
@export var record_stats: bool = false
@export_subgroup("Stats")
## The minimum time required to beat the stage in a single run, in seconds. Defaults to 5 minutes (300).
@export var ideal_time: int = 300
## Maximum number of Wiblings you think one should collect in a level. If left as [code]0[/code], automatically calculates score based on how much the player collected and/or missed spawned Wiblings.
@export var ideal_wibl: int = 0
## Here, you hook up the "Enemies" Node2D. This will cycle through the number of that Node2D's children.
@export var ideal_kill: Node2D
# The ideal number of deaths is always zero.
## The number of secrets in the stage.
@export var ideal_secr: int = 0

## Set restrictions on powerups and weapons here.
@export_group("Gear Restrictions")
@export_subgroup("Armory")
## If [code]true[/code], allows use of Charlie's melee weapon.[br]Set to
## [code]true[/code] if Charlie can use her melee weapon EVEN ONCE in the whole level.
@export var can_use_melee: bool = true
## If [code]true[/code], allows use of Charlie's ranged weapon.[br]Set to
## [code]true[/code] if Charlie can use her ranged weapon EVEN ONCE in the whole level.
@export var can_use_range: bool = true
@export_subgroup("Double Jump")
## If [code]true[/code], allows double jumping.[br]Set to
## [code]true[/code] if Charlie can double jump EVEN ONCE in the whole level.
@export var can_double_jump: bool = true
@export_subgroup("Dash")
## If [code]true[/code], allows dashing.[br]Set to
## [code]true[/code] if Charlie can dash EVEN ONCE in the whole level.
@export var can_dash: bool = true
## Multiply modifier to control your dash speed. Input a positive number to increase, and negative to decrease.
@export var dash_speed_mod: float = 0
## Multiply modifier to control how long the dash's cooldown is. Input a positive number to increase, and negative to decrease.
@export var dash_cooldown_mod: float = 0
@export_subgroup("Misc")
## If [code]true[/code], allows crystal powerups.[br]Set to [code]true[/code] if
## Charlie can use her crystal powerups EVEN ONCE in the whole level.
@export var can_use_crystals: bool = true
## The whitelist of crystals allowed in the stage.
@export_enum("crits", "invul", "bonus", "haste", "nuke", "random") var allowed_crystals: Array[String] = ["crits", "invul", "bonus", "haste", "nuke", "random"]
## If [code]true[/code], allows the Wibbie Goddess' Blessing to manifest.[br]Set
## to [code]true[/code] if Charlie can blessed EVEN ONCE in the whole level.
@export var wibbie_blessing_active: bool = true


@export_group("Music Options", "music_")
## If [code]true[/code], plays the music file declared in [code]music_play_on_init[/code].
@export var music_play_on_init: bool = false
## The filename of the music to be played on start. Make sure to include the filetype as well.
@export var music_filename: String = "null.ogg"
@export var music_fade_in: float = 0

@export_group("Debug")
# Sets custom Charlie spawn. Don't forget to disable when finished.
@export var test_charlie_spawn: int = 0

@onready var level_start_sfx : AudioStreamOggVorbis = load("res://assets/sounds/level_manager/level_start.ogg")
@onready var charlie: CharacterBody2D = get_node("Charlie")
@onready var camera: Camera2D = get_node("GameCamera")

func _ready() -> void:
	assert(charlie, "LevelInit sez: Where is Charlie, dawg?")
	assert(camera, "LevelInit sez: Where's the camera, dawg?")
	SignalBus.connect("reset", _reset)
	
	Staglobals.current_spawn = test_charlie_spawn
	Staglobals.money_slots.clear()
	Staglobals.money_slots_size = 0
	
	SoundManager.set_default_music_bus("Music")
	SoundManager.set_default_sound_bus("SFX")
	SoundManager.set_default_ui_sound_bus("UI SFX")
	
	if !obi_texture:
		obi_texture = load("res://assets/ui/obis/debug_room.png")
	Staglobals.current_stage_obi = obi_texture
	
	_reset()
	
	Staglobals.register_stage(stage_name, side, get_parent().scene_file_path) # Register stage details
	if record_stats:
		Staglobals.recording_stats = true 
		Staglobals.is_recording_time = true # Start stopwatch
		# Register everything else
		assert(ideal_kill, "LevelInit sez: No Enemies node specified. Just hook an empty Node2D to this if stage is intentionally enemy-less.")
		Staglobals.register_stage_stats(ideal_time, ideal_wibl, ideal_kill.get_child_count(), ideal_secr)
	else:
		Staglobals.recording_stats = false
	
	SignalBus.connect("freeze_frame", freeze_frame)
	get_parent().process_mode = Node.PROCESS_MODE_PAUSABLE

func whitelist() -> void:
	PlayerVar.can_use_melee = can_use_melee
	PlayerVar.can_use_range = can_use_range
	
	PlayerVar.can_double_jump = can_double_jump
	PlayerVar.can_dash = can_dash
	PlayerVar.dash_speed_mod = dash_speed_mod
	PlayerVar.dash_cooldown_mod = dash_cooldown_mod
	
	PlayerVar.can_use_crystals = can_use_crystals
	PlayerVar.allowed_crystals = allowed_crystals
	PlayerVar.wibbie_blessing_active = wibbie_blessing_active
	
	# if only ranged is allowed, switch immediately to ranged weapon and turn off weapon switching
	if !can_use_melee && can_use_range:
		if PlayerVar.melee:
			PlayerVar.melee = false
		PlayerVar.can_switch_weapon = false
	# if you can use both, allow weapon switching
	elif can_use_melee && can_use_range:
		PlayerVar.can_switch_weapon = true
	# if only melee is allowed, or if both weapons are banned, just turn off weapon switching
	else:
		PlayerVar.can_switch_weapon = false

func play_music() -> void:
	if music_play_on_init:
		MusicManager.play_music(music_filename, 0, music_fade_in)
	else:
		MusicManager.play_music("null.ogg", 0, music_fade_in)

# why the hell is the code for freeze frames in the fucking LevelInit code?
# couldn't we put this shit on the StaGlobals autoload instead?
func freeze_frame(time_scale: float, duration: float) -> void:
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1.0

func _reset() -> void:
	whitelist()
	play_music()
	Staglobals.actual_wibl = 0
	Staglobals.ideal_kill = 0
	if play_sound_on_start:
		SoundManager.play_ui_sound(level_start_sfx)

# thank you 4.5
func emit_signalbus(...args: Array) -> void:
	SignalBus.callv("emit_signal", args)

func emit_soundmanager(...args: Array) -> void:
	var actual_args: Array = args.duplicate()
	actual_args.remove_at(0)
	SoundManager.callv(args[0], actual_args)

func emit_musicmanager(...args: Array) -> void:
	var actual_args: Array = args.duplicate()
	actual_args.remove_at(0)
	MusicManager.callv(args[0], actual_args)

func medal_unlock(id: int) -> void:
	NG.medal_unlock(id)

func set_spawn(num: int) -> void:
	Staglobals.current_spawn = num

func show_hud(yes: bool) -> void:
	Staglobals.emit_signal("show_hud", yes)
