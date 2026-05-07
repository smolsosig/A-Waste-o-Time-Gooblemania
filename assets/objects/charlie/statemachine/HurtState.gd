extends CharlieState

@export var ground_state: CharlieState
@export var air_state: CharlieState
@export var sound: AudioStreamPlayer

func _on_animation_player_animation_finished(anim_name : String) -> void:
	charlie.grav_lock = false
	if anim_name == "hurt":
		if charlie.is_on_floor():
			next_state = ground_state
		else:
			next_state = air_state

func _on_charlie_hurtbox_component_hurt() -> void:
	emit_signal("interrupt_state", self) # switch to this state
	charlie.grav_lock = true # freezes charlie mid-air
	anim_player.play("hurt")
	sound.play()
	SignalBus.cam_shake.emit("small", false, self.name)
	if Staglobals.freeze_frame_on_hurt:
		SignalBus.emit_signal("freeze_frame", 0.05, 0.7)
