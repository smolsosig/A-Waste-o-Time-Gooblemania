extends Resource
class_name UserPreferences

# GAME
@export_enum("english", "spanish", "filipino") var language: int = 0
@export var show_hud: bool = true
@export var cam_shake: bool = true
# KEYS

# AUDIO
@export_range(-70, 0, 0.5) var master_volume: float = 0
@export_range(-70, 0, 0.5) var music_volume: float = 0
@export_range(-70, 0, 0.5) var sounds_volume: float = 0
# VIDEO
@export_enum("1080", "900", "720", "576") var window_resolution: int = 0
@export var borderless: bool = false
@export var display_mode: bool = true
@export var vsync: bool = true
@export var show_fps: bool = false

const save_path: String = "user://user_config.tres"

func save() -> void:
	ResourceSaver.save(self, save_path)

func new_config() -> void:
	language = language
	show_hud = show_hud
	cam_shake = cam_shake
	master_volume = master_volume
	music_volume = music_volume
	sounds_volume = sounds_volume
	window_resolution = window_resolution
	borderless = borderless
	display_mode = display_mode
	vsync = vsync
	show_fps = show_fps
	
	save()
