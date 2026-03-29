extends Node2D
class_name LevelManager

var current_level: Variant
var no_edging: bool = false
var pausable: bool = false
@onready var pause_menu: CanvasLayer = %PauseMenu
@onready var pause_music_dir: String = "res://assets/sounds/music/pause.ogg"
var pause_music: AudioStreamOggVorbis

func _ready() -> void:
	SignalBus.connect("set_pausable", set_pausable)
	SignalBus.connect("quit_game", quit_game)
	
	ResourceLoader.load_threaded_request(pause_music_dir)
	pause_music = ResourceLoader.load_threaded_get(pause_music_dir)

func hey_dipshit(level: Variant) -> void:
	current_level = level
	add_child(current_level)
	no_edging = false
	PlayerVar.can_switch_weapon = true

func set_pausable(allowed: bool) -> void:
	pausable = allowed

func kill_level() -> void:
	if current_level:
		current_level.queue_free()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_back") && pausable:
		if !get_tree().paused:
			get_tree().paused = true
			pause_menu.show_pause()
			MusicManager.pause_music(0.5)
			SoundManager.play_music(pause_music, 0, "Music")
		elif get_tree().paused && pause_menu.can_unpause:
			pause_menu.hide_pause()

func quit_game() -> void:
	if SignalBus.game_mode == 2 && !no_edging:
		PlayerVar.set_cursor(false)
		PlayerVar.can_switch_weapon = false
		no_edging = true
		pausable = false
		
		MusicManager.stop_music(3, 0)
		SoundManager.stop_music(3)
		MusicManager.stop_soundscapes()
		
		await Fade.fade_out(1, Color.BLACK, "Special").finished
		get_tree().paused = false
		%PauseMenu.hide()
		current_level.queue_free()
		get_parent().main_menu_load()


func _on_pause_menu_unpaused() -> void:
	get_tree().paused = false
	SoundManager.stop_music()
	MusicManager.resume_music(0, 0.5)
