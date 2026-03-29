extends CharlieState

@export var init_state: CharlieState
var death_sound: AudioStreamOggVorbis = load("res://assets/objects/charlie/sounds/death.ogg")

func _ready() -> void:
	SignalBus.connect("charlie_death", start)

func start() -> void:
	SignalBus.emit_signal("set_pausable", false) # disable pausing
	emit_signal("interrupt_state", self) # switch to this state
	charlie.grav_lock = true # freezes charlie mid-air
	charlie.velocity = Vector2i(0, 0) # no velocity
	SoundManager.play_ui_sound(death_sound)
	Staglobals.actual_dies += 1
	anim_player.play("death")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		charlie.grav_lock = false
		charlie.is_open_zoom_end = false
		SignalBus.emit_signal("reset")
