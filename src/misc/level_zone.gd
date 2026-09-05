class_name LevelZone extends VisibleOnScreenNotifier2D
## A rectangular region of 2D space that, when visible on screen, enables and shows a target node.
##
## Likewise, when not visible on screen, disables and hides the node.

func _ready() -> void:
	screen_entered.connect(on_screen)
	screen_exited.connect(off_screen)

func on_screen() -> void:
	if get_children():
		for child in get_children():
			child.process_mode = Node.PROCESS_MODE_INHERIT
			child.show()

func off_screen() -> void:
	if get_children():
		for child in get_children():
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.hide()
