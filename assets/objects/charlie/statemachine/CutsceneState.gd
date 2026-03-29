extends CharlieState

@export var ground_state: CharlieState
@export var air_state: CharlieState

var anim_picked: String
var cutscene_on: bool = false
var finished_action : String

func _ready() -> void:
	SignalBus.connect("charlie_cutscene", cutscene)
	SignalBus.connect("charlie_cutscene_stop", stop)

func cutscene(anim_name: String, finished: String, grav_lock: bool = false) -> void:
	emit_signal("interrupt_state", self) # switch to this state
	
	charlie.velocity = Vector2.ZERO
	
	cutscene_on = true
	
	charlie.grav_lock = grav_lock
	if finished:
		finished_action = finished
	if anim_name:
		anim_player.play(anim_name)
		anim_picked = anim_name
	else:
		anim_player.play("idle")
		anim_picked = anim_name
		# you think I give a fuck what idle anim the player picked?

func stop() -> void:
	if charlie.is_on_floor():
		next_state = ground_state
	else:
		next_state = air_state
	
	charlie.grav_lock = false
	
	if finished_action:
		SignalBus.emit_signal("charlie_cutscene_finished", finished_action)
		finished_action = ""

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if cutscene_on:
		if anim_name == anim_picked:
			stop()

# separate from tauntstate play_sound to avoid confusion. yes i am full of microplastics
func play_charlie_sound(sound: String) -> void:
	var sound_played : AudioStreamOggVorbis = load("res://assets/objects/charlie/sounds/%s.ogg" % sound)
	SoundManager.play_sound(sound_played)

# What this will do is interrupt the current state and play the desired
# animation. This state is reserved for cutscenes, dialogue, anywhere Charlie is
# not supposed to be receiving input from the player because something else is
# happening/needs said input.
# TODO replace with actual code as soon as I set up dialogue. Make it so that
# if it receives a signal from the signal bus to do a specific animation, it will
# play that animation, otherwise it will just play the idle loop.
