class_name StutterBegone9000 extends Node2D
## [b]WEB FIX:[/b] Teleports the child to Charlie's position and then
## immediately returns it back to whence it came.
##
## Meant to try and alleviate shader precompilation. This is my second attempt.

func _ready() -> void:
	var child: Node = get_child(0)
	child.global_position = PlayerVar.charlie_global_position
	await get_tree().create_timer(0.5).timeout
	child.global_position = global_position
