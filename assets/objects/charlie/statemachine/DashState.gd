extends CharlieState

@export var speed: float = 4000
@export var duration: float = 0.3
@export var cooldown: float = 0.25
@export var dash_particles: GPUParticles2D
@export var dash_sfx: AudioStreamPlayer2D
@onready var default_speed: float = speed
@export var air_trail: Line2D
var default_cooldown: int

@export_group("States")
@export var ground_state: CharlieState
@export var air_state: CharlieState
@export var attack_state: CharlieState

var target_position: Vector2
var target_direction: Vector2
@onready var dash_timer: Timer = get_node("DashTimer")
@onready var attack_window: Timer = get_node("AttackWindow")
@onready var cooldown_timer: Timer
@onready var momentum_window: Timer = get_node("MomentumWindow")

var dashed: bool = false
var pressed_attack: bool = false

var ground_init: bool = false
var extra_dash: bool = false

func _ready() -> void:
	# TODO implement checking savefile for player's selected dash
	cooldown_timer = get_node("CooldownTimer")
	dash_timer.wait_time = duration
	cooldown_timer.wait_time = cooldown
	
	if PlayerVar.dash_cooldown_mod:
		cooldown_timer.wait_time *= PlayerVar.dash_cooldown_mod
	
	attack_window.wait_time = dash_timer.wait_time - 0.02

func on_enter() -> void:
	# behold. whatever the fuck this is
	air_trail.run = true
	pressed_attack = false
	dash_sfx.stop()
	anim_player.play("dash")
	charlie.dashing = true
	charlie.grav_lock = true
	dash_particles.emitting = true
	dash_sfx.play()
	dashed = true
	dash_timer.start()
	
	if PlayerVar.dash_speed_mod:
		speed *= PlayerVar.dash_speed_mod
	else:
		speed = default_speed
	
	# this reuses roughly the same code as the throwing stars
	target_direction = charlie.global_position - charlie.get_global_mouse_position()
	charlie.velocity = target_direction.normalized() * (speed * -1)
	
	# makes sure Charlie slides onto the floor instead of dashing towards it
	if charlie.is_on_floor():
		if target_direction.normalized().y < 0.25:
			charlie.velocity.y = 0

func state_input(event : InputEvent) -> void:
	if (event.is_action_pressed("player_a")):
		if attack_window.is_stopped():
			pressed_attack = true

func state_process(_delta: float) -> void:
	if charlie.velocity.y == 0 && charlie.velocity.x != 0:
		if charlie.velocity.x > 0:
			charlie.velocity = Vector2(speed, 0)
		else:
			charlie.velocity = Vector2(speed * -1, 0)
	#if charlie.velocity.x == 0:
		#if charlie.velocity.y > 0:
			#charlie.velocity = Vector2(0, speed)
		#else:
			#charlie.velocity = Vector2(0, speed * -1)

func _on_dash_timer_timeout() -> void:
	if charlie.dashing == true:
		charlie.grav_lock = false
		if !pressed_attack:
			if charlie.is_on_floor():
				next_state = ground_state
			else:
				next_state = air_state
		else:
			next_state = attack_state

func on_exit() -> void:
	dash_timer.stop()
	dashed = true
	charlie.dashing = false
	charlie.velocity.y *= 0.6
	dash_particles.emitting = false
	cooldown_timer.start()
	momentum_window.start()
