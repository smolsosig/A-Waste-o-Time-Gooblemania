@icon("res://assets/misc/tools/icons/signpropdynamic.png")
extends AnimatedSprite2D

@export_enum("1x1", "1x3", "2x3") var sign_size: String = "1x1"
@export var event_name : String
var swapped: bool = false
@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	SignalBus.connect("reset", reset)
	animation = sign_size
	if event_name:
		SignalBus.connect("event_finished", sign_turn)

func sign_turn(event_namee : String) -> void:
	if event_name == event_namee:
		await get_tree().create_timer(0.25).timeout
		anim_player.current_animation = "%s-turn" % sign_size
		anim_player.play()
		swapped = true

func reset() -> void:
	if swapped:
		anim_player.play_backwards("%s-turn" % sign_size)
