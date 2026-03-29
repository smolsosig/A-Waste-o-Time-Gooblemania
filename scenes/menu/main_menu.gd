extends Node2D

#TODO REPLACE ALL THIS WITH ACTUAL CODE
signal level_start(level_name : String)

@export_enum("main", "play", "options", "achieve", "extras") var screen : int = 0

@export var camera : Camera2D

@export var main : Node2D
@export var play : Node2D
@export var options : Node2D
@export var achieve : Node2D
@export var extras : Node2D

@onready var title_music: AudioStreamOggVorbis = load("res://assets/sounds/music/titlemusic.ogg")
@onready var title_music2: AudioStreamOggVorbis = load("res://assets/sounds/music/titlemusic2.ogg")

func _ready() -> void:
	get_node("%TUTORIAL").connect("button_down", tut)
	get_node("%SIDE A").connect("button_down", yuh)
	get_node("%SIDE B").connect("button_down", yuh2)
	music_rng()

# eeeeheeheeheeee
func music_rng() -> void:
	var rng: int = (randi()%1000)
	if rng == 315:
		MusicManager.play_music("titlemusic2.ogg")
		print("MIDGETSAUSAGE sends her warmest regards!!! (Alt title music played)")
	else:
		print("Better luck next time! (You rolled %s.)" % rng)
		MusicManager.play_music("titlemusic.ogg")

func tut() -> void:
	emit_signal("level_start", "tutorial")

func yuh() -> void:
	emit_signal("level_start", "teststage_a")

func yuh2() -> void:
	emit_signal("level_start", "teststage_b")

func move_screen(screen_selected : int) -> void:
	screen = screen_selected
	
	var next_screen : Node2D
	match screen_selected:
		0:
			next_screen = main
		1:
			next_screen = play
		2:
			next_screen = options
		3:
			next_screen = achieve
		4:
			next_screen = extras
	
	var tween : Tween = create_tween()
	tween.tween_property(camera, "global_position", next_screen.global_position, 1).set_trans(Tween.TRANS_SINE)


func _on_button_pressed() -> void:
	emit_signal("level_start", "spy_a")
