extends Node2D

@export var animation : AnimationPlayer
@export var timer : Timer
@export var label : Label

var temp_damage : int = 0
var is_crit : bool = false

func _ready() -> void:
	SignalBus.connect("reset", reset)
	modulate = Color(1, 1, 1, 0)

func play_anim(damagenumber : int) -> void:
	reset() # something's causing the player to just not stop it
	label.text = "%s!" % damagenumber
	
	label.set_deferred("theme_override_colors/font_color", Color(1, 0.533, 0))
	label.set_deferred("theme_override_font_sizes/font_size", 50)
	
	if is_crit:
		label.set_deferred("theme_override_colors/font_color", Color.RED)
		label.set_deferred("theme_override_font_sizes/font_size", 80)
	
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	rotation_degrees = rng.randi_range(-20, 20)
	
	# ensures damage adds up instead of showing individual numbers
	if !timer.is_stopped():
		label.text = "%s!" % [(damagenumber + temp_damage)]
	else:
		label.text = "%s!" % damagenumber
	timer.stop()
	
	temp_damage += damagenumber
	animation.play("health_rise")
	is_crit = false
	timer.start()

func reset() -> void:
	animation.play("RESET")

func _on_timer_timeout() -> void:
	temp_damage = 0
