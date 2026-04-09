@icon("res://assets/misc/tools/icons/GameAnimationPlayer.png")
class_name GameAnimationPlayer extends AnimationPlayer
## AnimationPlayer that resets when Charlie herself resets.

## Animation to autoplay upon level (re)start. Useful for opening animations.[br][br]
## This is as opposed to setting which animation to autoplay via the AnimationPlayer.
@export var autoplay_anim_name: String
## Animation to autoplay when [code]Staglobals.current_spawn[/code] matches [code]autoplay_when_spawn_num[/code].[br][br]
## ... okay, okay. If you want, say, [code]"train_crashed"[/code] to play on the third checkpoint, you put [code]"train_crashed"[/code] here.
@export var autoplay_anim_when_spawn: String
## Autoplay [code]autoplay_anim_when_spawn[/code] when [code]Staglobals.current_spawn[/code] matches [code]autoplay_when_spawn_num[/code].[br][br]
## ... okay, okay. If you want, say, [code]"train_crashed"[/code] to play on the [b]third[/b] checkpoint, you put [code]3[/code] here.
@export var autoplay_when_spawn_num: int
## Autoplays the, well, autoplay animation at a random time.
@export var autoplay_at_random_time: bool = false
## If [code]true[/code], pauses the animation when Charlie undergoes the death animation.
@export var pause_when_death: bool = true

func _ready() -> void:
	SignalBus.connect("charlie_death", _death)
	SignalBus.connect("reset", _resetty)
	_resetty()

func _death() -> void:
	if pause_when_death: pause()

# so turns out there's already a func called _reset() on one of the inhereted classes
# which means i can't use that shit here roflmao
func _resetty() -> void:
	play("RESET")
	
	if autoplay_anim_when_spawn && (autoplay_when_spawn_num <= Staglobals.current_spawn):
		play(autoplay_anim_when_spawn)
		if autoplay_at_random_time: seek(randf_range(0, current_animation_length))
		return
	
	if autoplay_anim_name:
		play(autoplay_anim_name)
		if autoplay_at_random_time: seek(randf_range(0, current_animation_length))

## Dawg, this does exactly what it says.
func play_at_random_time(anim_name: StringName = &"") -> void:
	play(anim_name)
	seek(randf_range(0, current_animation_length))
