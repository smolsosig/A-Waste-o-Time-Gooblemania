extends CharlieState

@export var ground_state: CharlieState
@export var hitbox: Area2D

@onready var taunt_flair: String = "flairs/taunt_%s" % PlayerVar.taunt_flair

@export_group("DO NOT TOUCH!!!")
## Purely for the [code]AnimationPlayer[/code] to play sounds. [b]DO NOT CHANGE.[/b] Also, [b]NO MP3S OR WAVS!!!!![/b]
@export var sound : String

func on_enter() -> void:
	charlie.grav_lock = true
	SignalBus.emit_signal("taunt_pause", true)
	hitbox.monitorable = false
	anim_player.play(taunt_flair)

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == taunt_flair:
		next_state = ground_state

func play_sound() -> void:
	var sound_played : AudioStreamOggVorbis = load("res://assets/objects/charlie/sounds/taunt_%s.ogg" % sound)
	SoundManager.play_sound(sound_played)

func on_exit() -> void:
	charlie.grav_lock = false
	SignalBus.emit_signal("taunt_pause", false)
	hitbox.monitorable = true
