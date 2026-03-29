extends CharlieState

@export var buffer_timer: Timer
@export var jump_parti_timer: Timer
@export var run_particle: GPUParticles2D
@export var jump_particle: GPUParticles2D
@export var shuri_cooldown: Timer
@export var dash_cooldown: Timer
@export var idle_timer: Timer
@export var air_trail: Line2D
@export var midair_sound: AudioStreamPlayer

@export_group("States")
@export var air_state: CharlieState
@export var atk_state: CharlieState
@export var dash_state: CharlieState
@export var taunt_state: CharlieState
@export var idle_state: CharlieState

@onready var coyote_timer:= $CoyoteTimer
var jumped: bool = false
var rotation_called: bool = false
var ok_i_can_actually_jump_now: bool = false
var jump_buffered: bool = false

@onready var run_flair: String = "flairs/run_%s" % PlayerVar.run_flair
@onready var long_idle_flair: String = "flairs/long_idle_%s" % PlayerVar.long_idle_flair

func _ready() -> void:
	run_particle.emitting = false
	jump_particle.emitting = false

func on_enter() -> void:
	air_trail.run = false
	jumped = false
	coyote_timer.stop()
	jump_parti_timer.stop()
	idle_timer.start()
	dash_state.dashed = false
	air_state.has_double_jumped = false
	
	if get_parent().last_state == air_state:
		jump_particles()
	
	if jump_buffered:
		jump_buffered = false
		if Input.is_action_pressed("player_jump"):
			jump()
			jumped = true

func jump_particles() -> void:
	jump_particle.emitting = true
	jump_parti_timer.start()

func state_process(_delta : float) -> void:
	if !charlie.is_on_floor() and !jumped:
		coyote_timer.start()
		next_state = air_state
	
	if charlie.velocity.x && !charlie.is_on_wall():
		if current_anim != run_flair:
			if !charlie.is_walking:
				anim_player.play(run_flair)
			else:
				anim_player.play("walk")
		if !run_particle.emitting && !charlie.is_walking:
			run_particle.emitting = true
		
		if charlie.velocity.x > 0:
			particle_direction(-1)
		else:
			particle_direction(1)
	else:
		if current_anim != "idle":
			anim_player.play("idle")
		if run_particle.emitting:
			run_particle.emitting = false
	
	if charlie.velocity.x:
		if !idle_timer.is_stopped():
			idle_timer.stop()
	else:
		if idle_timer.is_stopped():
			idle_timer.start()
	
	# SHUT UP. SHUT UP. SHUT UP. SHUT THE FUCK UP
	if midair_sound.playing:
		midair_sound.stop()

func state_input(event : InputEvent) -> void:
	if (event.is_action_pressed("player_jump")) && ok_i_can_actually_jump_now:
		jump()
	if (event.is_action_pressed("player_a")) && PlayerVar.can_use_weapons:
		if PlayerVar.melee && PlayerVar.can_use_melee:
			attack()
		else:
			if PlayerVar.can_use_range:
				if shuri_cooldown.is_stopped():
					attack()
	if (event.is_action_pressed("player_taunt")):
		taunt()
	if (event.is_action_pressed("player_b")):
		if PlayerVar.can_dash && PlayerVar.dash && !dash_state.dashed:
			dash()

func _input(event : InputEvent) -> void:
	if (event.is_action_pressed("player_jump")) && current_state != self:
		jump_buffered = true

func particle_direction(num : int) -> void:
	run_particle.process_material.emission_shape_offset.x = 75 * num

func on_exit() -> void:
	run_particle.emitting = false
	jumped = false
	jump_buffered = false
	charlie.rotation = 0
	idle_timer.stop()

#region State Transitions
func jump() -> void:
	jump_particles()
	charlie.jump(false)
	jumped = true
	next_state = air_state

func attack() -> void:
	next_state = atk_state

func taunt() -> void:
	next_state = taunt_state

func dash() -> void:
	if dash_cooldown.is_stopped():
		next_state = dash_state

func _on_idle_timer_timeout() -> void:
	next_state = idle_state
#endregion

func _on_jump_parti_timer_timeout() -> void:
	jump_particle.emitting = false

# there was a bug that caused charlie to clip outside the train in gooblemania_a
# this shit is a band-aid because idek how to go about fixing that rofl sorry sodoj
func _on_no_jumpy_timeout() -> void:
	ok_i_can_actually_jump_now = true
