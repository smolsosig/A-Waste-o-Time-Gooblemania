class_name BasicGroundEnemy extends CharacterBody2D

signal died

@export var speed: int = 150
@export var starts_moving_left: bool = true
@export_enum("Immovable:0", "Light:1750", "Average:1400", "Heavy:1000") var weight_class: int = 0
var direction: Vector2 = Vector2.LEFT
var can_move: bool = true
var grav_lock: bool = false

@export_group("References")
@export var sprite: AnimatedSprite2D
@export var anim_player: GameAnimationPlayer
@export var edge_checker: RayCast2D
@export var health: EnemyHealthComponent
@export_subgroup("Sounds")
@export var hurt_sounds: GameAudioStreamPlayer2D
@export var death_sounds: GameAudioStreamPlayer2D

@onready var opening_position: Vector2 = global_position
var temp_velocity_y: float
var temp_velocity_y_lock: bool = false

func _ready() -> void:
	SignalBus.connect("taunt_pause", taunt_pause)
	SignalBus.connect("reset", _reset)
	anim_player.connect("animation_finished", _anim_finished)
	health.connect("health_changed", _on_health_changed)
	health.connect("died", _died_start)
	
	_reset()

func _reset() -> void:
	can_move = true
	global_position = opening_position
	anim_player.play("moving")
	velocity.y = 0
	if !starts_moving_left:
		swap()

#region movement
func _process(_delta: float) -> void:
	if !health.is_dead && is_on_floor():
		if !edge_checker.is_colliding() && get_floor_normal().x == 0:
			swap()

func _physics_process(delta: float) -> void:
	if health.is_dead:
		return
	
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_wall():
		swap()
	
	velocity.x = direction.x * speed
	
	move_and_slide()

func swap() -> void:
	direction.x *= -1
	sprite.scale.x *= -1

func taunt_pause(pause: bool) -> void:
	if pause:
		can_move = false
		grav_lock = true
	else:
		can_move = true
		grav_lock = false
		velocity.y = temp_velocity_y
#endregion

func _on_health_changed(_current_health: int, decrease: bool = true) -> void:
	if decrease:
		hurt_sounds.play()
		anim_player.play("hurt")
		velocity.y = weight_class * -1

func _anim_finished(anim_name: String) -> void:
	match anim_name:
		"hurt":
			anim_player.play("moving")
			can_move = true
		"died":
			_died()

func _died_start() -> void:
	death_sounds.play()
	anim_player.play("died")

func _died() -> void:
	can_move = false
	emit_signal("died")
