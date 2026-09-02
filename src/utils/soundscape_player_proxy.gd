@tool
@icon("res://assets/misc/tools/icons/SoundscapePlayer.png")
class_name SoundscapePlayerProxy extends Area2D
## Area2D that plays a given SoundscapePlayer.
##
## This is so you only have to set up one SoundscapePlayer, and any SoundscapePlayerProxy can just
## inherit that player's settings. Very convenient!

@warning_ignore("unused_private_class_variable")
@export_tool_button("Add Collider", "Add") var _button: Callable = _create_collider

## The [SoundscapePlayer] to grab the soundscape from.
@export var soundscape_player: SoundscapePlayer
## If [code]true[/code], overrides [member SoundscapePlayer.fade_in].
@export var override_fade_in: bool = false
## Yeah.
@export var fade_in: float = 0.5

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
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

func _create_collider() -> void:
	var new_collider: CollisionShape2D = CollisionShape2D.new()
	new_collider.shape = RectangleShape2D.new()
	new_collider.shape.size = Vector2(125, 200)
	new_collider.debug_color = Color(0.124, 0.601, 0.0, 0.42)
	
	add_child(new_collider)
	new_collider.owner = get_tree().edited_scene_root
