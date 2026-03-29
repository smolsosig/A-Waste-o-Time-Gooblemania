extends Area2D
class_name CharlieDetectableComponent

# The decision to make Charlie's DETECTABLE HITBOX separate from her ACTUAL
# HURTBOX was made because of complications that arose from AWoT attempt #1,
# when the two were the same. It caused CameraControllers and other
# Charlie-checking Area2Ds to break, forcing me to have the enemies themselves
# turn off their hitboxes during Charlie's "i-frames."
#
# By default, this should simply just... exist.

func _ready() -> void:
	SignalBus.connect("charlie_death", death)
	SignalBus.connect("reset", open_zoom)
	open_zoom()

func open_zoom() -> void:
	get_node("Hitbox").set_deferred("disabled", true)

func _on_charlie_open_zoom_endd() -> void:
	get_node("Hitbox").set_deferred("disabled", false)

func death() -> void:
	get_node("Hitbox").set_deferred("disabled", true)
