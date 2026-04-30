extends Area2D
class_name HittableComponent

signal interacted()
@export var interact_check: bool = false

@export var can_bounce_off_it: bool = false

func _ready() -> void:
	SignalBus.connect("reset", reset)

func interact() -> void:
	if !interact_check:
		emit_signal("interacted")
		interact_check = true

func reset() -> void:
	interact_check = false
