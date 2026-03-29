extends CharlieState

@export var ground_state: CharlieState
@export var air_state: CharlieState
@export var attack_state: CharlieState
@export var dash_state: CharlieState
@export var taunt_state: CharlieState
@export var shuri_cooldown: Timer
@export var dash_cooldown: Timer
var idle_anim_name: String = "flairs/longidle_%s" % PlayerVar.long_idle_flair

func on_enter() -> void:
	anim_player.play(idle_anim_name)

func state_input(event : InputEvent) -> void:
	if (event.is_action_pressed("player_left") || event.is_action_pressed("player_right")):
		next_state = ground_state
	if (event.is_action_pressed("player_jump")):
		ground_state.jump_particles()
		charlie.jump(false)
		ground_state.jumped = true
		next_state = air_state
	if (event.is_action_pressed("player_a")) && PlayerVar.can_use_weapons:
		if PlayerVar.melee && PlayerVar.can_use_melee:
				next_state = attack_state
		else:
			if PlayerVar.can_use_range:
				if shuri_cooldown.is_stopped():
					next_state = attack_state
	if (event.is_action_pressed("player_taunt")):
		next_state = taunt_state
	if (event.is_action_pressed("player_b")):
		if PlayerVar.can_dash && PlayerVar.dash && !dash_state.dashed:
			if dash_cooldown.is_stopped():
				next_state = dash_state

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"flairs/longidle_def":
			next_state = ground_state
