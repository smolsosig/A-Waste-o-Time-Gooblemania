extends CharlieState

@export var shuri_cooldown: Timer
@export var dash_cooldown: Timer
var idle_anim_name: String = "flairs/longidle_%s" % PlayerVar.long_idle_flair

func on_enter() -> void:
	anim_player.play(idle_anim_name)

func state_input(event : InputEvent) -> void:
	if (event.is_action_pressed("player_left") || event.is_action_pressed("player_right")):
		next_state = csm.states["GroundState"]
	if (event.is_action_pressed("player_jump")):
		csm.states["GroundState"].jump_particles()
		charlie.jump(false)
		csm.states["GroundState"].jumped = true
		next_state = csm.states["AirState"]
	if (event.is_action_pressed("player_a")) && PlayerVar.can_use_weapons:
		if PlayerVar.melee && PlayerVar.can_use_melee:
				next_state = csm.states["AttackState"]
		else:
			if PlayerVar.can_use_range:
				if shuri_cooldown.is_stopped():
					next_state = csm.states["AttackState"]
	if (event.is_action_pressed("player_taunt")):
		next_state = csm.states["TauntState"]
	if (event.is_action_pressed("player_b")):
		if PlayerVar.can_dash && PlayerVar.dash && !csm.states["DashState"].dashed:
			if dash_cooldown.is_stopped():
				next_state = csm.states["DashState"]

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"flairs/longidle_def":
			next_state = csm.states["GroundState"]
