extends Node2D

@export var animation : AnimationPlayer
@export var yuh: Sprite2D
var supercrit: bool = false

func _ready() -> void:
	SignalBus.connect("reset", reset)
	modulate = Color(1, 1, 1, 0)

func play_anim() -> void:
	reset() # something's causing the player to just not stop it
	
	if !supercrit:
		yuh.set_deferred("region_rect", Rect2(0.0, 0.0, 298.0, 176.0))
		animation.speed_scale = 1
	else:
		yuh.set_deferred("region_rect", Rect2(0.0, 176.0, 298.0, 176.0))
		animation.speed_scale = 0.75
	
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	rotation_degrees = rng.randi_range(-50, 50)
	animation.play("health_rise")

func reset() -> void:
	animation.play("RESET")
