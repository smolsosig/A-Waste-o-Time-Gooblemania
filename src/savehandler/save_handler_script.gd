extends Node

# PLACEHOLDER CODE (subd. of PLACEHOLDER GAMES) presents...
# The A WASTE o' TIME PROPRIETARY THREE-SAVEFILE HANDLING THINGIMAJIG
# Copyright (c) 2024-present PLACEHOLDER GAMES. All rights reserved.

# Godot is really assbent on reminding me this file exists for whatev reason.

var current_save_num : int = 1 #1, 2 or 3
var current_save: Variant
const save_path_base : String = "user://saves/"
const save_name : String = "charlie_mixtape_"
var save_path : String

@export var player_data_def : Node

# Simply checks if saves folder exists in user dir
func check_dir() -> void:
	var dir:= DirAccess.open(save_path_base)
	if !dir:
		dir = DirAccess.open("user://")
		dir.make_dir("saves")
		print("Saves folder not found. Created user://saves folder for you :3")

func file_select(save_num: int) -> void:
	check_dir()
	var config:= ConfigFile.new()
	save_path = "%s%s%s.awot" % [save_path_base, save_name, save_num]
	current_save = config.load(save_path)
	
	if current_save != OK:
		player_data_def.new_save(save_path)
	else:
		current_save_num = save_num
		print("Charlie Mixtape #%s found! (%s)" % [current_save_num, save_path])
	

#region SAVING
func save_level_info() -> void:
	var savefile := ConfigFile.new()
	savefile.load(save_path)
	
	var filename: String = Staglobals.current_stage_actual_fucking_filename
	savefile.set_value(filename, "completed", "Y")
	savefile.set_value(filename, "time", Staglobals.actual_time)
	savefile.set_value(filename, "wiblings", Staglobals.actual_wibl)
	savefile.set_value(filename, "kills", Staglobals.actual_kill)
	savefile.set_value(filename, "deaths", Staglobals.actual_dies)
	savefile.set_value(filename, "secrets", Staglobals.actual_secr)
	savefile.set_value(filename, "score", Staglobals.player_score)
	
	savefile.save(save_path)

# to save a specific thing
func save_thing(section: String, key: String, value: Variant) -> void:
	var savefile := ConfigFile.new()
	savefile.load(save_path) # THANK YOU CHIPRCHOPR FROM DISCORD
	
	savefile.set_value(section, key, value)
	savefile.save(save_path)
#endregion

#region LOADING
func get_save_info(level: String, info: String) -> Variant:
	var savefile := ConfigFile.new()
	savefile.load(save_path)
	return savefile.get_value(level, info)
#endregion

func clear_save() -> void:
	var savefile:= ConfigFile.new()
	savefile.load(save_path)
	savefile.clear()
	savefile.save(save_path)
	player_data_def.new_save(current_save_num, save_path)
	print("we just made a new thing")
