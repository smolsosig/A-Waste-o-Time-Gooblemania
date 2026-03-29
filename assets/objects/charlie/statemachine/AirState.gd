extends CharlieState

@export var air_trail: Line2D

@export_group("States")
@export var ground_state: CharlieState
@export var atk_state: CharlieState
@export var dash_state: CharlieState

@export_group("Timers")
@export var coyote_timer: Timer
@export var shuri_cooldown: Timer
@export var dash_cooldown: Timer

@onready var air_sound: AudioStreamPlayer = $MidairSound
var will_attack: bool = false
var has_double_jumped: bool = false

signal double_jumped

@onready var midair_flair: String = "flairs/midair_%s" % PlayerVar.midair_flair

func _ready() -> void:
	air_sound.pitch_scale = 1
	air_sound.play()
	air_sound.stream_paused = true

func on_enter() -> void:
	air_trail.run = true
	will_attack = false
	anim_player.play(midair_flair)
	air_sound.stream_paused = false

func state_process(delta: float) -> void:   
	sprite.spin(delta)
	
	if charlie.is_on_floor():
		sprite.rotation = 0
		next_state = ground_state

func state_input(event : InputEvent) -> void:
	if(event.is_action_pressed("player_jump")):
		if !coyote_timer.is_stopped():
			coyote_timer.stop()
			ground_state.jump_particles()
			charlie.jump(false)
		else:
			if !has_double_jumped:
				if PlayerVar.can_double_jump && PlayerVar.double_jump:
					charlie.jump(true)
					ground_state.jump_particles()
					has_double_jumped = true
					emit_signal("double_jumped")
					air_sound.pitch_scale = 1.5
					
					var tween: Tween = create_tween()
					tween.tween_property(air_sound, "pitch_scale", 1, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
	if (event.is_action_pressed("player_a")) && PlayerVar.can_use_weapons:
		if PlayerVar.melee && PlayerVar.can_use_melee:
				attack()
		else:
			if PlayerVar.can_use_range:
				if shuri_cooldown.is_stopped():
					attack()
	
	if (event.is_action_pressed("player_b")):
		if PlayerVar.can_dash && PlayerVar.dash && !dash_state.dashed:
			if !dash_state.ground_init:
				dash()
			else:
				if has_double_jumped:
					dash()

func attack() -> void:
	anim_player.play("prim_midair")
	next_state = atk_state
	will_attack = true

func dash() -> void:
	if dash_cooldown.is_stopped():
		next_state = dash_state

func on_exit() -> void:
	air_sound.stream_paused = true
	if !will_attack:
		sprite.stop_spinning()
