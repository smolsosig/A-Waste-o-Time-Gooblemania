class_name WandererChar extends CharacterBody2D

signal started_walking
signal stopped
signal swapped_directions(direction: int)

## The initial direction the WandererChar will move to. Defaults to Left.
@export_enum("Left", "Right", "Random") var initial_direction: String = "Left"
## Move speed. Defaults to 900.
@export var move_speed: float = 200
## Amount of seconds between every RNG roll. Defaults to one (1) second.
@export var rng_interval: float = 1
## The odds of randomly moving while standing still. 
@export_range(0, 1, 0.05) var move_chance: float = 0.5
## The odds of randomly stopping to stand while moving.
@export_range(0, 1, 0.05) var stand_chance: float = 0.5
## The odds of randomly switching directions.
@export_range(0, 1, 0.05) var switch_chance: float = 0.5
## If [code]true[/code], switches direction when stuck on wall.
@export var switch_when_on_wall: bool = true

@export_group("Fancy Accel-Decel Bullshit")
## Uses fancy bullshit like acceleration and friction.
## We don't need this often, but it's here if we do need it.[br][br]
## Normal people prefer the term "physics overrides".
@export var use_fancy_bullshit: bool = false
@export var acceleration: float
@export var friction: float

## Their current state.
@export_enum("Standing", "Moving") var _current_state: int = 1:
	set(value):
		if value:
			emit_signal("stopped")
		else:
			emit_signal("started_walking")
		
		_current_state = value

var direction: Vector2 = Vector2.LEFT
var _init_position: Vector2
var _internal_timer: float
var move_randomly: bool = true

func _ready() -> void:
	SignalBus.connect("reset", _reset)
	_init_position = global_position
	_reset()

func _reset() -> void:
	init_direction()
	global_position = _init_position

func _physics_process(delta: float) -> void:
	# I debated if create_timer() or using Timer nodes in general is a good idea
	# then again idk if subtracting a number every physics tick is a good idea
	if move_randomly:
		if _internal_timer <= 0:
			roll_rng()
			_internal_timer = rng_interval
		else:
			_internal_timer -= delta
	
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	# moving
	if !_current_state:
		if is_on_wall() && switch_when_on_wall:
			swap()
		
		if !use_fancy_bullshit: velocity.x = direction.x * move_speed
	else:
		if !use_fancy_bullshit: velocity.x = 0
	
	if !use_fancy_bullshit: move_and_slide()

func swap() -> void:
	direction.x *= -1
	emit_signal("swapped_directions", direction.x)

func roll_rng() -> void:
	# 0 stand 1 move
	var result: float
	result = randf()
	if _current_state && result <= move_chance:
		_current_state = 0
	elif !_current_state && result <= stand_chance:
		_current_state = 1
	
	# we use 1 - switch_chance to differentiate it from the move/stand chance
	# rather than using the left boundary, we use the right boundary
	# aren't I smart?
	if result >= 1 - switch_chance:
		swap()

func init_direction() -> void:
	match initial_direction:
		"Left":
			direction = Vector2.LEFT
		"Right":
			direction = Vector2.RIGHT
		"Random":
			if randi() % 2 == 0:
				direction = Vector2.LEFT
			else:
				direction = Vector2.RIGHT
