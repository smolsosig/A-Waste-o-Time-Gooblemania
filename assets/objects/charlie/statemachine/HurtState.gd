extends CharlieState

@export var sound: AudioStreamPlayer

func _on_animation_player_animation_finished(anim_name : String) -> void:
	charlie.grav_lock = false
	if anim_name == "hurt":
		next_state = csm.states["GroundState"] if charlie.is_on_floor() else csm.states["AirState"]

func _on_charlie_hurtbox_component_hurt() -> void:
	emit_signal("interrupt_state", self) # switch to this state
	charlie.grav_lock = true # freezes charlie mid-air
	anim_player.play("hurt")
	sound.play()
	SignalBus.cam_shake.emit("small", false)
	if Staglobals.freeze_frame_on_hurt:
		SignalBus.emit_signal("freeze_frame", 0.05, 0.7)
