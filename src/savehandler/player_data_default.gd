extends Node

# SAVE FILE DEFAULT CONTENTS
# This is what's created as the player makes a new file.

var check1: int
var check2: int
var check12: int

func new_save(save_path: String) -> void:
	var savefile : ConfigFile = ConfigFile.new()
	
	#region SIDE STATS
	# for EVERY SIDE of every level, there are six stats.
	# completed, time, wiblings, kills, deaths, secrets
	#region teststage1-a
	var name1: String = "teststage_a"
	savefile.set_value(name1, "completed", "N") # Y
	savefile.set_value(name1, "time", -1)
	savefile.set_value(name1, "wiblings", -1)
	savefile.set_value(name1, "kills", -1)
	savefile.set_value(name1, "deaths", -1)
	savefile.set_value(name1, "secrets", -1)
	#endregion
	#endregion
	
	
	#region PLAYER VARS
	savefile.set_value("playervar", "health", 120)
	savefile.set_value("playervar", "money", 50)
	#endregion
	
	
	#region EQUIPMENT
	#region PRIMARY
	savefile.set_value("equipment", "prim-enabled", true)
	savefile.set_value("equipment", "prim_type", "default") #/ "upgrade1" / "upgrade2"
	savefile.set_value("equipment", "prim_damage", 20)
	#endregion
	
	#region SECONDARY
	savefile.set_value("equipment", "secon_enabled", false)
	savefile.set_value("equipment", "secon_type", "default")
	savefile.set_value("equipment", "secon_damage", 20)
	#endregion
	
	#region OTHER SHIT
	#savefile.set_value("equipment", "thing1", true)
	#so on and so forth
	#endregion
	
	#region CRYSTALS
	savefile.set_value("crystal", "crystal1_have", false)
	#and so on and so forth
	
	savefile.set_value("crystal", "selected_crystal", "crits")
	savefile.set_value("crystal", "crits", false)
	savefile.set_value("crystal", "invul", false)
	savefile.set_value("crystal", "bonus", false)
	savefile.set_value("crystal", "quickfix", false)
	#endregion
	
	#region COSMETICS
	savefile.set_value("cosmetic", "longidle", "def")
	savefile.set_value("cosmetic", "run", "def")
	savefile.set_value("cosmetic", "midair", "def")
	savefile.set_value("cosmetic", "taunt", "def")
	#endregion
	
	savefile.save(save_path)
	print("New Charlie Mixtape generated at %s." % save_path)
