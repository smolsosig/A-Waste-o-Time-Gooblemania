@icon("res://assets/misc/tools/icons/PortalComponent.png")
extends Node
class_name PortalComponent
## Component for doors. Door in, door out...

## Custom fade-in transition.
@export var custom_fade_in: String = "DoorIn"
## Custom fade-out transition.
@export var custom_fade_out: String = "DoorOut"
## Custom sound. Root directory is [code]res://assets/sounds/[/code], so only include sounds from that folder.
@export var door_sound: String = "generalsfx/door-enter-generic"
## Where this door leads. It could be another [b]PortalComponent[/b], or it could just be some [b]Node2D[/b]. You decide.
@export var target_portal: Node2D
@onready var door_sound_sfx: AudioStreamOggVorbis = load("res://assets/sounds/%s.ogg" % door_sound)

func interacted() -> void:
	SignalBus.emit_signal("set_pausable", false)
	SignalBus.emit_signal("charlie_cutscene", "idle", "", false)
	SoundManager.play_ui_sound(door_sound_sfx)
	
	await Fade.fade_out(0.5, Color.BLACK, custom_fade_in).finished
	
	SignalBus.emit_signal("charlie_door_teleport", target_portal.global_position)
	
	await get_tree().create_timer(0.5).timeout
	await Fade.fade_in(0.3, Color.BLACK, custom_fade_out).finished
	SignalBus.emit_signal("charlie_cutscene_stop")
	SignalBus.emit_signal("set_pausable", true)
