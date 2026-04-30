extends Node
# Stage Globals. That's what it stands for.

var current_stage_fullname: String: # "1982Fort, Side A"
	set(value):
		emit_signal("stage_name_changed", value)
		current_stage_fullname = value 
var current_stage_file_location: String: # "res://scenes/game/levels/spy_a.scn"
	set(value):
		# this is incredibly retarded.
		# probably even more incredibly retarded that there apparently used to be a native function
		# that just returned the filename of the Node, but they took it out for the 4.x branch.
		# so uh, thanks Godot
		current_stage_filename = value.replace("%s/" % value.get_base_dir(), "")\
		.replace(".%s" % value.get_extension(), "")
		current_stage_file_location = value
var current_stage_filename: String # "spy_a"
var current_stage_name: String # "1982Fort"
var current_stage_side: String # "Side A" ???? idk exactly lmao i wrote this two years ago
var current_stage_obi: Texture2D

var current_spawn: int # USE current_spawn IN CONSOLE TO CHANGE
var current_spawn_anim: String = "null"

var recording_stats: bool = false

signal wiblings_collected(amount: int)
signal stage_name_changed(stage_name: String)

var hud_hidden: bool = false
signal show_hud(yes: bool)

var freeze_frame_on_hurt: bool = true

#region stats
#region time vars
var is_recording_time: bool = false
var elapsed_time: float = 0.0
var int_min: int
var int_sec: int
var int_ms: int
#endregion
var ideal_time: int = 0
var ideal_wibl: int = 0
var ideal_wibl_auto: bool = true
var ideal_kill: int = 0
var ideal_secr: int = 0
var actual_time: int = 0
var actual_wibl: int = 0:
	set(value):
		emit_signal("wiblings_collected", value)
		actual_wibl = value
var actual_kill: int = 0
var actual_dies: int = 0
var actual_secr: int = 0

var player_score: int = 0
#endregion

#region dialogue vars
signal dialogue_progression(key: String)
var even_has_dialogue: bool = false

@onready var dialogue_node: Node = get_node("%Dialogue")
var dialogue_script: Script
var dialogue: String = ""
var end_dialogue_signal: String = "!@#" # used to detect if dialogue is finished
#endregion

#region stopwatch code
func _process(delta: float) -> void:
	if is_recording_time:
		elapsed_time += delta
		time_check()

func time_check() -> void: # this is dumb as fuck
	actual_time = snapped(elapsed_time, 0.001) * 1000
	@warning_ignore("integer_division")
	int_min = actual_time / 60000
	int_sec = int(elapsed_time) % 60
	int_ms = int((elapsed_time - int(elapsed_time)) * 1000)
#endregion

func register_stage(stage_name: String, side: String, file_location: String) -> void:
	var pending_side: String
	match side:
		"sideless":
			pending_side = ""
		"A", "B", "C":
			pending_side = ", Side %s" % side
	
	var new_stage_name: String = "%s%s" % [stage_name, pending_side]
	if new_stage_name != current_stage_fullname:
		current_stage_fullname = new_stage_name
		current_stage_name = stage_name
		current_stage_side = side
		current_stage_file_location = file_location
	
	print("YOU ARE NOW TUNED IN TO: %s" % current_stage_fullname.to_upper())
	add_dialogue(current_stage_file_location)

func register_stage_stats(time: int, wibl: int, kill: int, secr: int) -> void:
	ideal_time = time
	if !wibl:
		ideal_wibl_auto = true
	else:
		ideal_wibl_auto = false
	ideal_wibl = wibl
	ideal_kill = kill
	ideal_secr = secr

#region dialogue funcs
func add_dialogue(file_location: String) -> void:
	var new_file_location: String = file_location.replace(".%s" % file_location.get_extension(), "_dialog.gd")
	
	if ResourceLoader.exists(new_file_location):
		dialogue_script = load(new_file_location)
		dialogue_node.set_script(dialogue_script)
		print("%s_dialog.gd found!" % current_stage_filename)
		even_has_dialogue = true
	else:
		# we allow the game to continue as usual
		print("%s_dialog.gd does not appear to exist. Unless intentional, please fix ASAP." % current_stage_filename)
		even_has_dialogue = false

func return_dialogue(key: String) -> String:
	if even_has_dialogue:
		# so turns out you have to use has(). because I am dumb and retarded
		if dialogue_node.dialogue.has(key):
			dialogue = dialogue_node.dialogue[key]
		else:
			dialogue = end_dialogue_signal
	else:
		dialogue = end_dialogue_signal
	
	return dialogue
#endregion

#region money cleanup
var money_slots: Array = []
var money_slots_size: int = 0:
	set(value):
		while value > money_limit:
			money_slots.front().queue_free()
			money_slots.pop_front()
			value -= 1
		money_slots_size = value
var money_limit: int = 20
#endregion
