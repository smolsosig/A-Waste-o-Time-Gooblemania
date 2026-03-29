@icon("res://assets/misc/tools/icons/SoundscapePlayer.png")
class_name SoundscapePlayerProxy extends Area2D
## Area2D that plays a given SoundscapePlayer.
##
## This is so you only have to set up one SoundscapePlayer, and any SoundscapePlayerProxy can just
## inherit that player's settings. Very convenient!

@export var soundscape_player: SoundscapePlayer
@export var override_fade_in: bool = false
@export var fade_in: float = 0.5

func _ready() -> void:
	if !soundscape_player:
		print("%s has no specified soundscape_player. Deleting itself..." % name)
		queue_free()
		return
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	
	connect("body_entered", _on_body_entered)

func play_soundscape(_override_fade_in: float) -> void:
	soundscape_player.play_soundscape(_override_fade_in)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Charlie" && soundscape_player:
		soundscape_player.play_soundscape(soundscape_player.fade_in if !override_fade_in else fade_in)
