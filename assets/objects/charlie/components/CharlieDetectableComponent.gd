extends Area2D
class_name CharlieDetectableComponent

# The decision to make Charlie's DETECTABLE HITBOX separate from her ACTUAL
# HURTBOX was made because of complications that arose from AWoT attempt #1,
# when the two were the same. It caused CameraControllers and other
# Charlie-checking Area2Ds to break, forcing me to have the enemies themselves
# turn off their hitboxes during Charlie's "i-frames."
#
# By default, this should simply just... exist.

@onready var _hitbox: CollisionShape2D = get_node("Hitbox")

func _ready() -> void:
	SignalBus.connect("charlie_death", death)
	SignalBus.connect("reset", open_zoom)
	SignalBus.connect("charlie_cutscene", _fuck_you)
	SignalBus.connect("charlie_cutscene_finished", _fuck_you_too)
	SignalBus.connect("charlie_cutscene_stop", _fuck_you_as_well)
	open_zoom()

func open_zoom() -> void:
	_hitbox.set_deferred("disabled", true)

func _on_charlie_open_zoom_endd() -> void:
	_hitbox.set_deferred("disabled", false)

func death() -> void:
	_hitbox.set_deferred("disabled", true)

func _fuck_you(_a: String, _b: String, _c: bool) -> void:
	_hitbox.set_deferred("disabled", true)

func _fuck_you_too(_bitch: String) -> void:
	_hitbox.set_deferred("disabled", false)

func _fuck_you_as_well() -> void:
	_hitbox.set_deferred("disabled", false)
