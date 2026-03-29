@icon("res://assets/misc/tools/icons/SoundscapePlayer.png")
class_name SoundscapePlayer extends Area2D
## Area2D that plays a specified ambience sound file when Charlie collides with it.

@export var soundscape: AudioStreamOggVorbis
@export var fade_in: float = 1

func _ready() -> void:
	if !soundscape:
		print("%s has no specified soundscape file. I will not work properly!" % name)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	
	connect("body_entered", _on_body_entered)

func play_soundscape(override_fade_in: float = fade_in) -> void:
	if soundscape.resource_path != MusicManager.return_current_soundscape():
		MusicManager.play_soundscape(soundscape, override_fade_in)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Charlie" && soundscape:
		play_soundscape()
