class_name LevelZone extends VisibleOnScreenNotifier2D
## A rectangular region of 2D space that, when visible on screen, enables and shows a target node.
##
## Likewise, when not visible on screen, disables and hides the node.

func _ready() -> void:
	screen_entered.connect(toggle_visibility.bind(true))
	screen_exited.connect(toggle_visibility.bind(false))

func toggle_visibility(gotta_show: bool = true) -> void:
	if get_children():
		for child in get_children():
			child.process_mode = Node.PROCESS_MODE_INHERIT if gotta_show else Node.PROCESS_MODE_DISABLED
			if child is CanvasItem: child.visible = gotta_show
