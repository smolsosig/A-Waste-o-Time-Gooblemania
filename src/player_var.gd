extends Node

# THESE ARE PER LEVEL

#region Health
signal new_target_health # notifies Charlie that her health needs to be changed
signal change_health_display # mainly notifies HUD that her health's changing
signal change_hud_maybe # well

@export_enum("NONE", "HURTING", "HEALING") var health_state : int = 0:
	set(new_value):
		health_state = new_value
		emit_signal("change_hud_maybe")
var health_speed : float:
	set(new_value):
		if new_value < 0.01:
			new_value = 0.01
		health_speed = new_value
var base_health : int = 125 # This is the only value saved in savefile
var target_health : int = base_health:
	set(new_value):
		target_health = clampi(new_value, 0, base_health)
		emit_signal("new_target_health")
var health : int = base_health:
	set(new_value):
		health = new_value
		emit_signal("change_health_display")
#endregion
#region Combat
signal weapon_changed(melee: bool)

var deaths: int = 0:
	set(value):
		if value == 10:
			NG.medal_unlock(88761)
		deaths = value
var supercrits: int = 0:
	set(value):
		if value == 10:
			NG.medal_unlock(88759)
		supercrits = value

var can_switch_weapon: bool = true
var can_use_weapons: bool = true
var melee: bool = true:
	set(new_value):
		melee = new_value
		emit_signal("weapon_changed", melee)

var prima_base_damage : int = 20
var secon_base_damage : int = 16
# crit stuff. RNG will pick a random number between 0 and crit_range (1024)
# by default, crit hits have a 7.5% chance of happening (crit_chance == 77)
# super crits have a 0.7% chance of happening (super_crit_chance == 7)
var crit_range : int = 1024
var crit_chance : int = 77
var super_crit_chance : int = 7
var delivered_damage : int
# this is for the enemies receiving the damage i think?
# it is only ever used once and it's to make the damage numbers bigger and bolder. lol
var crit : bool = false

func atk_rng(is_melee: bool = true, guaranteed_crit: bool = false) -> float:
	var damage: int
	var random_numbery: float
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.randomize()
	
	if is_melee:
		damage = prima_base_damage
	else:
		damage = secon_base_damage
	
	# decide if we're even gonna crit at all
	if !guaranteed_crit:
		random_numbery = random.randi_range(0, crit_range)
	else:
		random_numbery = random.randi_range(0, crit_chance)
	
	if random_numbery > crit_chance:
		# if we get any other number, deal ordinary damage
		damage = randi_range((damage * 0.99), (damage * 1.1))
		# yes, this can easily get overpowered when base damage is big! Too bad!
		crit = false
		
		if is_melee:
			SignalBus.emit_signal("freeze_frame", 0.05, 0.5)
		else:
			SignalBus.emit_signal("freeze_frame", 0.05, 0.3)
		SignalBus.emit_signal("cam_shake", "verysmall")
	else:
		# if we get a number < crit_chance, decide if normal crit or super crit
		random_numbery = random.randi_range(0, crit_chance)
		if random_numbery > super_crit_chance:
			# normal crit
			SignalBus.emit_signal("crit_delivered", false)
			damage = randi_range((damage * 2.5), (damage * 3)) # because 3 was too much???????
			SignalBus.emit_signal("freeze_frame", 0.05, 0.75)
			SignalBus.emit_signal("cam_shake", "small")
			supercrits += 1
		else:
			# super crit
			SignalBus.emit_signal("crit_delivered", true)
			damage = randi_range((damage * 9.5), (damage * 10))
			SignalBus.emit_signal("freeze_frame", 0.05, 1.5)
			SignalBus.emit_signal("cam_shake", "small")
		crit = true
	
	return damage
#endregion
#region Armory
@warning_ignore("shadowed_global_identifier")
var range: bool = true
var prima_upgrade: int = 0
var secon_upgrade: int = 0

## these CAN BE TURNED ON OR OFF AT ANY GIVEN MOMENT
var double_jump: bool = true
var dash: bool = true
var crystalcrown: bool = true
var selected_crystal: String = "crits"
var crystalcollection: Array[String] = [] # ["crits", "invul", "bonus", "haste", "nuke", "random"]
var wibbie_blessing: bool = true
#endregion
#region flairs
var run_flair: String = "def"
var long_idle_flair: String = "def"
var midair_flair: String = "def"
var taunt_flair: String = "def"

#endregion
#region Initial Whitelists
var can_use_melee: bool = true
var can_use_range: bool = true

var can_double_jump: bool = true:
	set(n):
		double_jump = n
		can_double_jump = n
var can_dash: bool = true:
	set(n):
		dash = n
		can_dash = n
var dash_speed_mod: float = 0
var dash_cooldown_mod: float = 0

var can_use_crystals: bool = true:
	set(n):
		crystalcrown = n
		can_use_crystals = n
var allowed_crystals: Array[String] = ["crits", "invul", "bonus", "quickfix"]
var wibbie_blessing_active: bool = true
#endregion
#region Cursor
# Why is this placed in PlayerVar? Because there's no other good place for me to put it. LOL
var def_cursor: CompressedTexture2D = load("res://assets/ui/cursors/default.png")
var crosshair: CompressedTexture2D = load("res://assets/ui/cursors/crosshair.png")
var cursor_x: float
var cursor_y: float
var hotspot_coords: Vector2

func ready_cursor() -> void:
	cursor_x = def_cursor.get_width() / 2.0
	cursor_y = def_cursor.get_height() / 2.0
	hotspot_coords = Vector2(cursor_x, cursor_y)
	
	Input.set_custom_mouse_cursor(def_cursor, Input.CURSOR_ARROW, hotspot_coords)

func set_cursor(be_crosshair: bool = false) -> void:
	if !be_crosshair:
		Input.set_custom_mouse_cursor(def_cursor, Input.CURSOR_ARROW, hotspot_coords)
	else:
		Input.set_custom_mouse_cursor(crosshair, Input.CURSOR_ARROW, hotspot_coords)
#endregion

func _ready() -> void:
	SignalBus.connect("charlie_death", add_death)
	ready_cursor()
	load_config()

func add_death() -> void:
	deaths += 1

#region settings
const resolutions: Array = [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1440, 810),
	Vector2i(1280, 720),
	Vector2i(1024, 576),
	Vector2i(800, 450),
]
const max_fps: Array = [
	30,
	60,
	120,
	240,
	0
]
const languages: Array = [
	"", # English
	"es",
	"tl",
]

const save_path: String = "user://user_prefs.cfg"
var config: ConfigFile

var language: int
var show_hud: bool = true:
	set(value):
		SignalBus.emit_signal("show_hud", value)
		show_hud = value
var cam_shake: bool = true
var show_fps: bool = false:
	set(value):
		SignalBus.emit_signal("show_fps", value)
		show_fps = value

#region save/load settings FILE
func load_config() -> void:
	config = ConfigFile.new()
	var err: Error = config.load(save_path)
	
	if err != OK:
		print("user_prefs.cfg not found. New one generated!")
		new_config()
	else:
		print("user_prefs.cfg found!")
		
	load_settings()

func save_config() -> void:
	config.save(save_path)

func save_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)

func return_setting(section: String, key: String) -> Variant:
	return config.get_value(section, key)

func new_config() -> void:
	config = ConfigFile.new()
	
	config.set_value("game", "language", 0)
	config.set_value("game", "show_hud", true)
	config.set_value("game", "money_limit", 20)
	config.set_value("game", "cam_shake", true)

	config.set_value("audio", "master_volume", 0)
	config.set_value("audio", "music_volume", 0)
	config.set_value("audio", "sounds_volume", 0)
	
	config.set_value("video", "display_mode", false)
	config.set_value("video", "borderless", false)
	config.set_value("video", "vsync", true)
	config.set_value("video", "show_fps", false)
	config.set_value("video", "max_fps", 4)

	config.save(PlayerVar.save_path)
#endregion
func centre_window() -> void:
	@warning_ignore("integer_division")
	var centre_screen: Vector2 = DisplayServer.screen_get_position() + DisplayServer.screen_get_size()/2
	var window_size: Vector2 = get_window().get_size_with_decorations()
	get_window().set_position(centre_screen - window_size/2)

func load_settings() -> void:
	language = config.get_value("game", "language", 0)
	show_hud = config.get_value("game", "show_hud", true)
	Staglobals.money_limit = config.get_value("game", "money_limit", 20)
	cam_shake = config.get_value("game", "cam_shake", true)

	AudioServer.set_bus_volume_db(0, config.get_value("audio", "master_volume", 0))
	AudioServer.set_bus_volume_db(1, config.get_value("audio", "music_volume", 0))
	AudioServer.set_bus_volume_db(2, config.get_value("audio", "sounds_volume", 0))

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, config.get_value("video", "borderless"))
	if config.get_value("video", "display_mode", true):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if config.get_value("video", "vsync", true): DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	show_fps = config.get_value("video", "show_fps", false)
	Engine.max_fps = max_fps[config.get_value("video", "max_fps", 4)]
#endregion
