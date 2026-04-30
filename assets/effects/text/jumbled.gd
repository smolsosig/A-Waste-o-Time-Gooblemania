@tool
extends RichTextEffect
class_name TextEffectJumbled

# Syntax: [j][/j]
var bbcode: String = "j"

var VOWELS: Array[int] = [ord("a"), ord("e"), ord("i"), ord("o"), ord("u"),
			  ord("A"), ord("E"), ord("I"), ord("O"), ord("U")]
var CHARS: Array[int] = [ord("&"), ord("$"), ord("!"), ord("@"), ord("*"), ord("#"), ord("%")]
var SPACE: int = ord(" ")

var _was_space: bool = false


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var c: float = char_fx.glyph_index
	
	#if not _was_space and not char_fx.relative_index == 0 and not c == SPACE:
	if not _was_space and not c == SPACE:
		var t: float = char_fx.elapsed_time + char_fx.glyph_index * 10.2 + char_fx.range.x * 2
		t *= 4.3
		if c in VOWELS or sin(t) > 0.0:
			char_fx.glyph_index = CHARS[int(t) % len(CHARS)]
	
	_was_space = c == SPACE
	
	return true
