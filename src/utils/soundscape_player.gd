@tool
@icon("res://assets/misc/tools/icons/SoundscapePlayer.png")
class_name SoundscapePlayer extends Area2D
## Area2D that plays a specified ambience sound file when Charlie collides with it.

@warning_ignore("unused_private_class_variable")
@export_tool_button("Add Collider", "Add") var _button: Callable = _create_collider

## The soundscape to play.
@export var soundscape: AudioStreamOggVorbis
## How many seconds the soundscape will fade in.
@export var fade_in: float = 0.35
## If [code]true[/code], this [SoundscapePlayer] will be used to stop any/all soundscapes playing upon Charlie entering. [member fade_in] will then be used to dictate how many seconds to fade out the soundscapes.
@export var stop_soundscapes: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if !soundscape && !stop_soundscapes:
		print("%s has no specified soundscape file. I will not work properly!" % name)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	
	connect("body_entered", _on_body_entered)

## Plays the soundscape.
func play_soundscape(override_fade_in: float = fade_in) -> void:
	if soundscape.resource_path != MusicManager.return_current_soundscape():
		MusicManager.play_soundscape(soundscape, override_fade_in)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Charlie":
		if soundscape: play_soundscape()
		else: MusicManager.stop_soundscapes(fade_in)

func _create_collider() -> void:
	var new_collider: CollisionShape2D = CollisionShape2D.new()
	new_collider.shape = RectangleShape2D.new()
	new_collider.shape.size = Vector2(125, 200)
	new_collider.debug_color = Color(0.124, 0.601, 0.0, 0.42)
	
	add_child(new_collider)
	new_collider.owner = get_tree().edited_scene_root
