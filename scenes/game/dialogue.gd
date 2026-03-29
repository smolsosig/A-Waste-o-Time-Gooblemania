extends CanvasLayer
## A Waste o' Time's proprietary (not) dialogue system. 

@export var dialogue_text: RichTextLabel
@export var dialogue_box : Sprite2D
@export var anim_player: AnimationPlayer
@export var cont_anim_player : AnimationPlayer
@export var continue_signer: Sprite2D
@export var typing_sound: AudioStreamPlayer

## Overall checks if we're actually doing dialogue. (so we don't accidentally do
## shit while it's showing/hiding itself.)
var dialoguing: bool = false
## Self-explanatory.
var is_displaying_text: bool = false
## Keeps track of the current key.
var current_key: String
## keeps track of how many lines we've got.
var dialogue_progression: int = 1
## I don't remember what this does.
var paused: bool = false

var orig_text: String

var punct_found: bool = false

var cont_sprite: Resource = load("res://assets/ui/dialoguebox/cont.png")
var stop_sprite: Resource = load("res://assets/ui/dialoguebox/stop.png")

func _ready() -> void:
	visible = false
	SignalBus.connect("dialogue_display", display)

func display(key: String) -> void:
	visible = true
	cont_anim_player.play("hide")
	dialogue_text.text = ""
	dialogue_progression = 1
	current_key = key
	anim_player.play("show")

# simply displays text, and skips to end automatically if you press SPACE
func _process(_delta: float) -> void:
	if is_displaying_text:
		if dialogue_text.visible_ratio != 1:
			if !paused:
				dialogue_text.visible_characters += 1
				last_two_displayed_chars()
		else:
			is_displaying_text = false
			cont_anim_player.play("bop")
			typing_sound.stop()

# pausing for punctuation becomes wack if we don't strip all the bbcode
func strip_bbcode(text: String) -> String:
	var regex: RegEx = RegEx.new()
	var text_without_tags: String
	regex.compile("\\[.*?\\]")
	text_without_tags = regex.sub(text, "", true)

	return text_without_tags

# if we don't pause for these punctuation marks, dialogue ends up feeling wack
func last_two_displayed_chars() -> void:
	if dialogue_text.visible_characters > 1:
		var visible_text: String = strip_bbcode(orig_text).left(dialogue_text.visible_characters)
		var text_check: String = visible_text.right(2)
		var param: int = 0
		
		match text_check:
			". ", "? ", "! ":
				param = 1
			", ", ": ", "; ", "- ", ") ", "~ ":
				param = 2
		
		if param:
			pause_text(param, visible_text)

# actually pauses
func pause_text(end: int, _debug: String) -> void:
	paused = true
	punct_found = true
	typing_sound.stream_paused = true
	var teemer: float
	
	if end == 1:
		teemer = 0.35 # 0.35
	else:
		teemer = 0.15 # 0.15
	
	await get_tree().create_timer(teemer).timeout
	paused = false
	typing_sound.stream_paused = false

# actual text progression
func progress_text() -> void:
	dialogue_text.visible_ratio = 0
	cont_anim_player.play("hide")
	dialoguing = true
	
	var new_key: String = "%s%s" % [current_key, dialogue_progression]
	orig_text = Staglobals.return_dialogue(new_key)
	if orig_text != Staglobals.end_dialogue_signal:
		dialogue_text.text = orig_text
		is_displaying_text = true
		dialogue_progression += 1
		cont_sprite_check()
		random_starter()
		Staglobals.emit_signal("dialogue_progression", new_key)
	else:
		anim_player.play("hide")
		dialoguing = false

# if end of dialogue, display crystal. else, display arrow
func cont_sprite_check() -> void:
	if Staglobals.return_dialogue("%s%s" % [current_key, dialogue_progression]) != Staglobals.end_dialogue_signal:
		continue_signer.texture = cont_sprite
	else:
		continue_signer.texture = stop_sprite

func end_dialogue() -> void:
	SignalBus.emit_signal("charlie_cutscene_finished", "dialog_%s" % current_key)
	SignalBus.emit_signal("charlie_cutscene_stop")

# simply waits for the player to press LEFT MOUSE/"A" OR SPACE/"JUMP" to progress
func _input(event: InputEvent) -> void:
	if dialoguing:
		if event.is_action_pressed("player_a"):
			skip_or_dip()
		if event.is_action_pressed("player_jump"):
			skip_or_dip()

# actually skips dialogue
func skip_or_dip() -> void:
	if is_displaying_text:
		dialogue_text.visible_ratio = 1
	else:
		progress_text()

func random_starter() -> void:
	var random_pos: float = randf_range(0, typing_sound.stream.get_length())
	typing_sound.play(random_pos)
