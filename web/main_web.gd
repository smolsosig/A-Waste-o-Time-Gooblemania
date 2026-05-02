extends Node

var current_level : Variant
var load_level_dir : String
var req_scene : Variant
var loading : int = 0
var load_type : int = 2 #1 = literally anything else, 2 = level loaded
var ldscrn : Variant

const main_menu_dir : String = "res://web/scenes/menu/stageselect_web.scn"
const level_dir_pref : String = "res://web/scenes/game/levels/"
const level_dir_suff : String = ".scn"

@onready var main_menu : Node = $StageselectWeb

@onready var level_container : Node = $LevelContainer

@onready var loading_screen : Variant = load("res://scenes/loading.scn")
@onready var timer_value : float  = 1

func _ready() -> void:
	SignalBus.main_game_running = true
	SignalBus.desktop = false
	SignalBus.connect("level_load", level_load)
	SignalBus.connect("main_menu_load", main_menu_load)
	Fade.fade_in(1)
	SignalBus.game_mode = 1
	print("Game mode: %s" % SignalBus.game_mode)

func main_menu_connect(loaded_scene : Variant) -> void:
	#This is where you put the main_menu connect things.
	main_menu = loaded_scene

func _process(_delta : float) -> void:
	if loading != 0:
		var load_status : Variant = ResourceLoader.load_threaded_get_status(req_scene)
		if load_status == ResourceLoader.THREAD_LOAD_LOADED:
			loading = 0
			load_em_up(load_type)

#region Loading level
#THIS IS STRICTLY FOR LEVELS, PLEASE GOD DON'T USE THIS TO LOAD OTHER SCENES
#YES I'M AWARE I SHOULDN'T DUPLICATE FUNCTIONS BUT JESUS FUCKING CHRIST THERE'S A LOT OF MENTAL
#LOAD INVOLVED IF I COMBINE THEM INTO A SINGLE FUNCTION SO PLEASE PLEASE PLEASE PLEASE PLEASE PLEASE
#PLEASE PLEASE PLEASE PLEASE PLEASE PLEASE DO NOT USE THIS FOR LOADING SCENES OTHER THAN LEVELS

#load level
func level_load(level_name: String) -> void:
	SoundManager.stop_music(3)
	MusicManager.stop_music(3, 0)
	await Fade.fade_out(1, Color.BLACK, "Special").finished
	SignalBus.emit_signal("switch_scene_web_bandaid")
	if main_menu:
		main_menu.queue_free()
	else:
		level_container.kill_level()
	
	if !level_name:
		level_name = "teststage_b"
	
	req_scene = "%s%s%s" % [level_dir_pref, level_name, level_dir_suff]
	print("Requested to load '%s'." % req_scene)
	ResourceLoader.load_threaded_request(req_scene)
	
	ldscrn = loading_screen.instantiate()
	add_child(ldscrn)
	await Fade.fade_in(1).finished
	loading = 1
	load_type = 2
	SignalBus.game_mode = 0

#add loaded scene as child
func load_em_up(mode : int) -> void:
	await Fade.fade_out(1).finished
	ldscrn.queue_free()
	
	var loaded_scene : Variant = ResourceLoader.load_threaded_get(req_scene).instantiate()
	
	if mode == 2:
		level_container.hey_dipshit(loaded_scene)
		mode = 2
		SignalBus.game_mode = 2
	else:
		add_child(loaded_scene)
		main_menu_connect(loaded_scene)
		Fade.fade_in(1)
		SignalBus.game_mode = 1
	print("Game mode: %s" % SignalBus.game_mode)
#endregion

func main_menu_load() -> void:
	req_scene = main_menu_dir
	print("Requested to load '%s'." % req_scene)
	ResourceLoader.load_threaded_request(req_scene)
	SignalBus.emit_signal("switch_scene_web_bandaid")
	
	ldscrn = loading_screen.instantiate()
	add_child(ldscrn)
	await Fade.fade_in(1).finished
	loading = 1
	load_type = 1
	SignalBus.game_mode = 0
	print("Game is in load mode.")
