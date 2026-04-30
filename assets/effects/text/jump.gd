@tool
extends RichTextEffect
class_name TextEffectJump

# Syntax: [jump angle=3.141][/jump]
var bbcode: String = "jump"

const SPLITTERS = [ord(" "), ord("."), ord(",")]

var _w_char: int = 0
var _last: int = 999


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if char_fx.range.x < _last or char_fx.glyph_index in SPLITTERS:
		_w_char = char_fx.range.x
	
	_last = char_fx.range.x
	var t: float = abs(sin(char_fx.elapsed_time * 8.0 + _w_char * PI * .025)) * 10.0
	var angle: float = deg_to_rad(char_fx.env.get("angle", 180))
	char_fx.offset.x += sin(angle) * t
	char_fx.offset.y += cos(angle) * t
	return true
