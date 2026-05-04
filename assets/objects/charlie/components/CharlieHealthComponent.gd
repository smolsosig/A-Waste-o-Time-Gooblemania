@icon("res://assets/misc/tools/icons/health.png")
class_name CharlieHealthComponent extends Node

var health: int
var target_health: int
var health_speed: float

@onready var health_timer:= $HealthTimer
@onready var grace_timer:= $GraceTimer
var impending_doom_sfx : AudioStreamOggVorbis = load("res://assets/sounds/ui/lastchance.ogg")

signal die

# TODO base_health should be set to savefile's base_health
func _ready() -> void:
	reset_health()
	
	health_timer.connect("timeout", health_timeout)
	PlayerVar.connect("new_target_health", health_change_init)
	SignalBus.connect("reset", reset_health)

func health_change_init() -> void:
	if !health_timer.is_stopped():
		health_timer.stop()
	
	# if Charlie gets hurt while healing, it simply stops Charlie from healing
	if PlayerVar.health_state == 2 && PlayerVar.target_health < PlayerVar.health:
		PlayerVar.target_health = PlayerVar.health
	
	health_timer.wait_time = PlayerVar.health_speed
	health_change()

func health_change() -> void: # there is a reason this is no longer a while loop
	if PlayerVar.health != PlayerVar.target_health:
		health_timer.wait_time = PlayerVar.health_speed
		if PlayerVar.health > PlayerVar.target_health:
			PlayerVar.health -= 1
			PlayerVar.health_state = 1
		else:
			PlayerVar.health += 1
			PlayerVar.health_state = 2
		health_timer.start() # and why this doesn't await a timer timeout anymore
	else:
		PlayerVar.health_state = 0

func health_timeout() -> void:
	health_change()
	
	if PlayerVar.health == 0:
		SoundManager.play_ui_sound(impending_doom_sfx)
		grace_timer.start()
		SignalBus.emit_signal("charlie_about_to_die")

func _on_grace_timer_timeout() -> void:
	if PlayerVar.health == 0:
		SignalBus.emit_signal("charlie_death")
		print("!!!!!!!!!!!!!!!!!!!! charlie ded !!!!!!!!!!!!!!!!!!!!")

func reset_health() -> void:
	PlayerVar.health = PlayerVar.base_health
	PlayerVar.target_health = PlayerVar.base_health
	PlayerVar.health_speed = 0.007
