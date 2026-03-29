@tool
@icon("res://assets/misc/tools/icons/FlickeringLight2D.png")
class_name FlickeringPointLight2D extends PointLight2D

@export_enum(
	"Normal",
	"Flicker 1",
	"Slow Strong Pulse",
	"Candle 1",
	"Fast Strobe",
	"Gentle Pulse 1",
	"Flicker 2",
	"Candle 2",
	"Candle 3",
	"Slow Strobe 4",
	"Flicker (\"Quake Classic\")",
	"Slow Pulse (No Fade)",
	"Underwater Light"
	) var pattern: int = 0
@export var speed: float = 10.0  # frames per second
@export var max_energy: float = 2.0  # maximum brightness

var _time: float = 0.0
var _frame: int = 0
var _pattern: String

const patterns: Array[String] = [
	"m", # normal
	"mmnmmommommnonmmonqnmmo", # FLICKER (first variety)
	"abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba", # SLOW STRONG PULSE
	"mmmmmaaaaammmmmaaaaaabcdefgabcdefg", # CANDLE (first variety)
	"mamamamamama", # FAST STROBE
	"jklmnopqrstuvwxyzyxwvutsrqponmlkj", # GENTLE PULSE 1
	"nmonqnmomnmomomno", # FLICKER (second variety)
	"mmmaaaabcdefgmmmmaaaammmaamm", # CANDLE (second variety)
	"mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa", # CANDLE (third variety)
	"aaaaaaaazzzzzzzz", # SLOW STROBE (fourth variety)
	"mmamammmmammamamaaamammma", # FLUORESCENT FLICKER (the Quake classic)
	"abcdefghijklmnopqrrqponmlkjihgfedcba", # SLOW PULSE NOT FADE TO BLACK
	"mmnnmmnnnmmnn" # UNDERWATER LIGHT MUTATION
]

func _ready() -> void:
	_frame = 1 + randi() % patterns[pattern].length()

func _process(delta: float) -> void:
	_pattern = patterns[pattern]

	_time += delta
	if _time >= 1.0 / speed:
		_time = 0.0
		_frame = (_frame + 1) % _pattern.length()
		var chara: String = _pattern[_frame]
		var value: float = clamp(chara.unicode_at(0) - 'a'.unicode_at(0), 0, 25)
		energy = max_energy * (value / 25.0)
