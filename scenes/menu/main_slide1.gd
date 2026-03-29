extends Node2D

@export var main : Node2D

var select : int = 0

func _input(event : Variant) -> void:
	if main.screen == 0:
		if event.is_action_pressed("player_up"):
			move_select(true)
		if event.is_action_pressed("player_down"):
			move_select(false)

func move_select(up : bool = true) -> void:
	if up:
		select -= 1
	else:
		select += 1
	
	if select == 5:
		select = 0
	elif select == -1:
		select = 4

func _on_hover_play_pressed() -> void:
	main.move_screen(1)

func _on_hover_options_pressed() -> void:
	main.move_screen(2)

func _on_hover_achieve_pressed() -> void:
	main.move_screen(3)

func _on_hover_extra_pressed() -> void:
	main.move_screen(4)

func _on_hover_quit_pressed() -> void:
	if OS.has_feature("pc"):
		get_tree().quit()
