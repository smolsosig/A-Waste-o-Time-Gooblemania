@icon("res://assets/misc/tools/icons/Charlie.png")
extends CharacterBody2D

@export var speed: float = 1000.0

@export var anim_sprite: AnimatedSprite2D
@export var state_machine: CharlieStateMachine
@export var init_state: CharlieState

@export_group("Walking")
@export var is_walking: bool = false:
	set(value):
		if value:
			speed = init_speed * walk_speed_multiplier
		else:
			speed = init_speed
		is_walking = value

@export var walk_speed_multiplier: float = 0.6
@onready var init_speed: float = speed

# This is bad, bad archaic code and more importantly it's bad code I don't know how to replace.
# It's quite literally just Charlie's old jump code taken straight from AWoT attempt #1.
# But it works so well that I don't even wanna bother changing it.
@export_group("Jump Vars", "jump_")
@export var jump_height: float = 400.0
@export var jump_time_to_peak: float = 0.3
@export var jump_time_to_descent: float = 0.35

var can_move: bool

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak) * -1.0
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent) * -1.0
@onready var jump_timer: Timer = %JumpTimer

@onready var jump_sound: AudioStreamOggVorbis = preload("res://assets/objects/charlie/sounds/jump.ogg")
var jump_timer_lock: bool = false
var um_yea_im_def_pressing_jump_lol: bool = false

var grav_lock: bool = false
var direction: Vector2 = Vector2.ZERO

var rotate_lock: bool = false
var normal: Vector2

var dashing: bool = false

var is_open_zoom_end: bool = false
signal open_zoom_endd

func _ready() -> void:
	jump_timer.wait_time = jump_time_to_peak
	SignalBus.connect("charlie_door_teleport", _door_teleport)
	SignalBus.connect("charlie_change_pos", _door_teleport)
	SignalBus.connect("charlie_walk", _walk)
	
	global_position.y -= 2

# All of this is also just Charlie's old code from AWoT attempt #1.
# Again, much like the jump code, they all work fine so there's no reason to
# change it that much, unless it really gets in the way.

func _physics_process(delta : float) -> void:
	if !grav_lock && !is_on_floor():
		velocity.y += get_gravity_a() * delta
	
	#jump thing
	#if is_jumping:
	if (Input.is_action_just_released("player_jump") && \
	!jump_timer.is_stopped() && !um_yea_im_def_pressing_jump_lol && !dashing):
		jump_timer.stop()
		jump_timer_lock = true
		velocity.y = 0 #I want to kill myself. I genuinely want to fucking kill myself
	
	if is_on_floor():
		if jump_timer_lock:
			jump_timer.stop()
			jump_timer_lock = false
	
	#input shit-inator
	direction = Input.get_vector("player_left", "player_right", "dummy", "dummy")
	
	if direction.x != 0 && state_machine.check_if_can_move():
		velocity.x = direction.x * speed
	else:
		if !dashing:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	update_facing_direction()

func jump(double: bool) -> void:
	if !double:
		SoundManager.play_sound(jump_sound)
	else:
		SoundManager.play_sound_with_pitch(jump_sound, 1.25)
	velocity.y = jump_velocity
	jump_timer.start()

func update_facing_direction() -> void:
	if state_machine.check_if_can_move() || state_machine.check_can_change_direction():
		if direction.x > 0:
			anim_sprite.flip_h = false
		elif direction.x < 0:
			anim_sprite.flip_h = true

func get_gravity_a() -> float:
	if (velocity.y < 0.0):
		return jump_gravity
	else:
		return fall_gravity

func open_zoom_end() -> void:
	emit_signal("open_zoom_endd")
	is_open_zoom_end = true

func special_jump() -> void:
	SoundManager.play_sound(jump_sound)
	velocity.y = jump_velocity
	um_yea_im_def_pressing_jump_lol = true
	await get_tree().create_timer(0.1).timeout
	um_yea_im_def_pressing_jump_lol = false

func _door_teleport(t_position: Vector2, spawn: bool = false, carry_velocity: bool = false) -> void:
	global_position = t_position
	if !carry_velocity:
		velocity = Vector2.ZERO
	
	# in the strange occasion that the CharlieSpawner is above-ground
	if spawn:
		velocity.y = 999
		move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_switchweapon") && is_open_zoom_end:
		if PlayerVar.can_switch_weapon:
			if !PlayerVar.melee:
				PlayerVar.melee = true
			else:
				PlayerVar.melee = false

func _walk(yes: bool = false) -> void:
	is_walking = yes
