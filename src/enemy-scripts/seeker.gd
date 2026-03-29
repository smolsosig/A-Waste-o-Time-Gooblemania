class_name SeekerChar extends WandererChar

@export_group("Movement")
## This is relative to Charlie's speed.
@export_range(0.75, 1.25) var chase_speed_multiplier: float = 1.03
@export_range(0, 1.0, 0.05) var cooldown_speed_multiplier: float = 0.75
@export var jump_velocity: float = 1315.0
var can_jump: bool = true

@export_group("Chase Settings")
@export var seeker_area2D: Area2D
@export var chase_delay: float = 0.5
@export var chase_cooldown: float = 0.5
@export var jump_on_obstacles: bool = true

## Do not touch this in the inspector. I will kill you.
@export_enum("Neutral", "Spotted", "Chasing", "Cooldown") var current_state_seeker: int = 0:
	set(value):
		if value == 2:
			move_speed = 1100 * chase_speed_multiplier
		elif value == 1 || value == 3:
			move_speed = orig_move_speed * cooldown_speed_multiplier
		else:
			move_speed = orig_move_speed
			
		current_state_seeker = value

var charlie_ref: Node2D
var charlie_position: Vector2
var chase_move_direction: float

var timer: float = 0
var timer_ongoing: bool = false

@onready var orig_move_speed: float = move_speed

func _ready() -> void:
	super()
	if use_fancy_bullshit:
		orig_move_speed *= 2
		move_speed *= 2
	seeker_area2D.connect("body_entered", _body_entered)
	seeker_area2D.connect("body_exited", _body_exited)

func _process(delta: float) -> void:
	if timer_ongoing:
		timer += delta
		
		# conditions
		if current_state_seeker == 1 && timer < chase_delay:
			current_state_seeker = 2
			timer_ongoing = false
		elif current_state_seeker == 3 && timer < chase_cooldown:
			current_state_seeker = 0
			timer_ongoing = false

func _physics_process(delta: float) -> void:
	super(delta)
	
	if !is_on_floor():
		velocity.y += get_gravity().y * delta
		if can_jump:
			velocity.y += jump_velocity * -1
			can_jump = false
	else:
		if !can_jump: can_jump = true
	
	if is_on_wall() && jump_on_obstacles && can_jump:
		velocity.y += jump_velocity * -1
		can_jump = false
	
	if current_state_seeker == 2:
		charlie_position = charlie_ref.global_position
		if charlie_position > global_position && chase_move_direction != 1:
			chase_move_direction = 1
			emit_signal("swapped_directions", direction.x)
		elif charlie_position < global_position && chase_move_direction != -1:
			chase_move_direction = -1
			emit_signal("swapped_directions", direction.x)
		
		direction.x = chase_move_direction
	
	var velocity_weight: float = delta * acceleration
	velocity.x = lerp(velocity.x, direction.x * move_speed, velocity_weight)
	move_and_slide()

func _body_entered(body: Node2D) -> void:
	current_state_seeker = 1
	timer = 0
	timer_ongoing = true
	charlie_ref = body
	
func _body_exited(_body: Node2D) -> void:
	current_state_seeker = 3
	timer = 0
	charlie_ref = null
