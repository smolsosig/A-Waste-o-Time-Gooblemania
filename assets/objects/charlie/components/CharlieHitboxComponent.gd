@icon("res://assets/misc/tools/icons/hurtbox.png")
class_name CharlieHurtboxComponent extends Area2D
# This hurtbox is EXCLUSIVELY for combat-related purposes.

@export var anim_sprite : AnimatedSprite2D

@onready var iframe_timer : Timer = $InvinciTimer
@onready var collision : CollisionShape2D = $Hurtbox

signal hurt

func _ready() -> void:
	open_zoom()
	SignalBus.connect("charlie_cutscene", cutscene)
	SignalBus.connect("charlie_cutscene_stop", cutscene_end)
	SignalBus.connect("charlie_death", die_disable)
	SignalBus.connect("reset", open_zoom)
	
func damage(time : float, damagee : float) -> void:
	collision.set_deferred("disabled", true)
	
	if PlayerVar.target_health < PlayerVar.health:
		PlayerVar.health_speed -= (PlayerVar.health_speed * 0.2)
		PlayerVar.target_health -= damagee
	else:
		PlayerVar.health_speed = time
		PlayerVar.target_health = PlayerVar.health - damagee
	
	emit_signal("hurt")
	iframe_timer.start()
	anim_sprite.modulate = Color.CORAL

func _on_invinci_timer_timeout() -> void:
	collision.set_deferred("disabled", false)
	anim_sprite.modulate = Color.WHITE

# we turn off Charlie getting hurt in cutscenes as to prevent any bugs
func cutscene(_a: String, _b: String, _c: bool) -> void:
	set_deferred("monitorable", false)

# then we let her back in the wild as soon as the cutscene finishes
func cutscene_end() -> void:
	set_deferred("monitorable", true)

func open_zoom() -> void:
	monitorable = false
	collision.disabled = false

func _on_charlie_open_zoom_endd() -> void:
	set_deferred("monitorable", true)

func die_disable() -> void:
	set_deferred("monitorable", false)
