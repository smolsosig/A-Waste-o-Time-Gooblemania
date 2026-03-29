extends CharacterBody2D

# spinny shit
@export var sprite: Sprite2D
@export var speed: float = 4000
@export var spin_speed: int = 20
@export var num_bounces: int = 0
@export var init_offset: int = 150
@export var trail_length: int = 100

var spin_direction: int
var init_spin_lock: bool = false

# positions
var init_position: Vector2
var target_position: Vector2
var target_direction: Vector2

var last_play: bool = false
var stop_spinning: bool = false

@onready var trail: Line2D = get_node("Trail2D")

func _ready() -> void:
	trail.lengthy = trail_length
	init_position.y -= init_offset
	global_position = init_position
	target_position = get_global_mouse_position()
	target_direction = init_position - target_position
	
	velocity = target_direction.normalized() * (speed * -1)
	
func _process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		if num_bounces != 0:
			velocity = velocity.bounce(collision.get_normal())
			num_bounces -= 1
			get_node("WorldImpact").play()
		else:
			if !last_play:
				get_node("WorldImpact").play()
				get_node("Trail2D").run = false
				last_play = true
				stop_spinning = true
				await get_tree().create_timer(0.1).timeout
				if !get_node("AttackHitbox").dont_disappear:
					queue_free()
	
	spin(delta)
	
#region spinning code
func spin(delta : float) -> void:
	if !stop_spinning:
		if !init_spin_lock:
			init_spin()
		else:
			rotation += (spin_speed * spin_direction) * delta

func init_spin() -> void:
	if target_direction.x > 0:
		spin_direction = -1
	else:
		spin_direction = 1
		sprite.flip_h = true
		
	init_spin_lock = true
#endregion

# after 5 seconds, simply unceremoniously kill yourself
func _on_timer_timeout() -> void:
	queue_free()

func _on_sfx_timer_timeout() -> void:
	queue_free()
