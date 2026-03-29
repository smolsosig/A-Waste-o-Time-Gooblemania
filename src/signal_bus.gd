extends Node
# Here we go again!
var awot_version: String = "March 29, 2026 Build"
@export_enum("loading", "menu", "ingame", "misc") var game_mode : int = 1
var desktop: bool = true

signal shuriken_spawn

signal level_load(level_name : String)
signal main_menu_load

signal event_finished(event_name: String)

signal set_pausable(pause: bool)

# to pause while taunting
signal taunt_pause(pause: bool)
# make Charlie do an anim. "finished" when something's supposed to happen after
# dude what did I even have in mind when I wrote some of this shit
signal charlie_cutscene(anim_name: String, finished: String, grav_lock: bool)
# literally what is this even for
signal charlie_cutscene_finished(action: String)
signal charlie_cutscene_stop

# should charlie walk? by default, no. emitting this w/o args, no
signal charlie_walk(yes: bool)

# charlie is about to die and it's your fault (grace timer running)
signal charlie_about_to_die
# death signals. before charlie dies (right as the death anim plays)
# use to pause enemies or whatnot
signal charlie_death
# after charlie dies (right before the respawn schtuff happens)
# use to reset sequences or restore enemies
signal reset

# camera stuf
signal stop_cam_please_dawg
signal cam_ok_u_can_follow_now
signal cam_shake(shake_type: String, normal_speed: bool)

# why the fuck are there two operations for basically doing the same goddamn thing?
signal charlie_door_teleport(t_position: Vector2)
signal charlie_change_pos(t_position: Vector2, spawn: bool)

# freeze frame
signal freeze_frame(duration: float, time_scale: float)

# damage num
signal damage_num(damage: int)

# signal the HUD that it delivered a crit
signal crit_delivered(supercrit: bool)

signal show_hud(show: bool) # not to be confused with Staglobals.show_hud
signal show_fps(show: bool)
signal cam_shake_allowed(yes: bool)

signal dialogue_display(key: String)

# stage end
signal stage_end
signal end_results_kill_yourself
signal quit_game

signal show_obi

# 67
