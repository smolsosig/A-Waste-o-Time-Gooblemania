extends CanvasLayer

@export_enum("A", "B", "C") var side : String = "A"

@export_group("Hookables")
@export var anim_player : AnimationPlayer

@export_subgroup("Headline")
@export var stage_title: Label

@export_subgroup("Scores")
@export var time_score_label: Label
@export var wibl_score_label: Label
@export var kill_score_label: Label
@export var dies_score_label: Label
@export var secr_score_label: Label

@export_subgroup("Stats")
@export var time_stats: Label
@export var wibl_stats: Label
@export var kill_stats: Label
@export var dies_stats: Label
@export var secr_stats: Label

@export_subgroup("Verdict")
@export var verdict: Label

@export_group("Do Not Touch")
##This one variable needed to be exported because the [code]AnimationPlayer[/code]
##couldn't find it otherwise. As per the name, please do not touch.
@export var ready_to_exit: bool = false

@onready var music: AudioStreamOggVorbis = load("res://assets/sounds/music/this_is_gonna_get_me_dmcad.ogg")

#region Actual scores
var time_score: int = 0
var wibl_score: int = 0
var kill_score: int = 0
var dies_score: int = 0
var secr_score: int = 0
var player_score: float = 0.0
#endregion

func _ready() -> void:
	Staglobals.is_recording_time = false
	
	SignalBus.emit_signal("charlie_cutscene", "idle", "", true)
	PlayerVar.health = PlayerVar.base_health
	PlayerVar.target_health = PlayerVar.base_health
	SoundManager.stop_music()
	MusicManager.stop_soundscapes()
	
	if Staglobals.recording_stats:
		anim_player.play("SideA")
		calculate_scores_root()
		show_scores()
		Staglobals.player_score = player_score
		SaveHandler.save_level_info()
	else:
		anim_player.play("SideA_nostats")
	
	visible = true
	stage_title.text = Staglobals.current_stage_fullname.to_upper()

##region score calculation garbage thank u noth
func calculate_scores_root() -> void:
	time_score = calculate_scores_2(Staglobals.elapsed_time, Staglobals.ideal_time, true)
	wibl_score = calculate_scores_1(Staglobals.actual_wibl, Staglobals.ideal_wibl)
	kill_score = calculate_scores_1(Staglobals.actual_kill, Staglobals.ideal_kill)
	dies_score = calculate_scores_2(Staglobals.actual_dies, 0, false)
	secr_score = calculate_secrets(Staglobals.actual_secr, Staglobals.ideal_secr)
	
	# FIXME for whatever reason this gives out an incorrect, rounded-off result.
	# does making the combined scores a float before dividing by two help?
	player_score = float(time_score + wibl_score + kill_score + dies_score + secr_score) / 2
#
### FOR USE WITH WIBLINGS AND KILLS
func calculate_scores_1(player_count: float, max_count: int) -> int:
	if max_count != 0: # checks if no enemies
		if max_count != 1: # checks if more than one enemy
			if player_count != 0: # checks if you even did anything. can't divide by zero it seems
				var percent: float = (float(player_count) / float(max_count)) * 100
				return ceil(percent / 25)
			else:
				return 0
		else:
			if player_count: return 4
			else: return 0
	else: return 4
#
### FOR USE WITH TIME AND DEATHS
func calculate_scores_2(player_count: float, min_count: int, time: bool = false) -> int:
	if player_count <= min_count: return 5
	else:
		# despite the name, this doesn't actually divide anything.
		# more accurately it only subtracts. lol. retarded fucking name
		var divisor: int
		if time: divisor = 60 # for every minute, deduct score by 1
		else: divisor = 1
#
		var final_score: int = 5
		var temp_count: int = player_count
		
		while !(temp_count <= min_count):
			if final_score != 0: 
				final_score -= 1
				temp_count -= divisor
			else:
				break # stop! stop! he's already dead!
		
		if final_score < 0: final_score = 0
		return final_score

func calculate_secrets(secrets_found: int, secret_count: int) -> int:
	if secret_count != 0:
		if secret_count != 1:
			@warning_ignore("integer_division")
			var percent: int = (float(secrets_found) / float(secret_count)) * 100
			@warning_ignore("integer_division")
			return floor(percent / 50)
		else:
			if secrets_found: return 2
			else: return 0
	else: return 2
#endregion
#
func show_scores() -> void:
	time_score_label.text = str(time_score)
	wibl_score_label.text = str(wibl_score)
	kill_score_label.text = str(kill_score)
	dies_score_label.text = str(dies_score)
	secr_score_label.text = str(secr_score)
	
	@warning_ignore("shadowed_global_identifier")
	var min: String = str(Staglobals.int_min).pad_zeros(2)
	@warning_ignore("shadowed_global_identifier")
	var sec: String = str(Staglobals.int_sec).pad_zeros(2)
	var mil: String = str(Staglobals.int_ms).pad_zeros(2).left(2)
	
	time_stats.text = "Time completed: %s:%s:%s" % [min, sec, mil]
	wibl_stats.text = "Wiblings collected: %s" % Staglobals.actual_wibl
	kill_stats.text = "Asses whooped: %s" % Staglobals.actual_kill
	dies_stats.text = "Times died: %s" % Staglobals.actual_dies
	secr_stats.text = "Secrets found: %s" % Staglobals.actual_secr
	
	var font_size: int
	if !step_decimals(player_score):
		verdict.text = str(player_score).left(-2)
		if player_score != 10:
			font_size = 150
		else:
			font_size = 125
	else:
		verdict.text = str(player_score)
		font_size = 138
	verdict.set_deferred("theme_override_font_sizes/font_size", font_size)
	
	print("PLACEHOLDER REVIEWS PRESENTS.... %s!" % Staglobals.current_stage_fullname.to_upper())
	print("=======================================================")
	print("IDEAL TIME: %ss. GOT: %ss. SCORE: %s." % [Staglobals.ideal_time, Staglobals.elapsed_time, time_score])
	print("IDEAL WIBLINGS: %s. GOT: %s. SCORE: %s." % [Staglobals.actual_wibl, Staglobals.ideal_wibl, wibl_score])
	print("ENEMY COUNT: %s. KILLED: %s. SCORE: %s." % [Staglobals.ideal_kill, Staglobals.actual_kill, kill_score])
	print("DEATHS: %s. SCORE: %s." % [Staglobals.actual_dies, dies_score])
	print("SECRETS: %s. FOUND: %s. SCORE: %s." % [Staglobals.ideal_secr, Staglobals.actual_secr, secr_score])
	print("=======================================================")
	print("VERDICT: %s/10" % [player_score])

func play_music() -> void:
	# TODO replace with match side A B C to appro music
	MusicManager.play_end(side)

func play_music2() -> void:
	$EndMusic.play_with_fade(5)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() && ready_to_exit:
		SignalBus.emit_signal("level_load", next_level_decider())
		ready_to_exit = false

func next_level_decider() -> String:
	var new_level_filename: String
	match side:
		"A":
			new_level_filename = "%s%s" % [Staglobals.current_stage_filename.left(-1), "b"]
		"B":
			new_level_filename = "%s%s" % [Staglobals.current_stage_filename.left(-1), "c"]
	
	return new_level_filename
