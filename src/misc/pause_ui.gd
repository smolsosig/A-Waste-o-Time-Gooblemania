extends VBoxContainer
class_name PauseUI

var buttons: Array

func _ready() -> void:
	for child in get_children():
		buttons.append(child)
	connect_buttons()

func connect_buttons() -> void:
	pass

func disable_buttons() -> void:
	for item: Button in buttons:
		item.disabled = true

func enable_buttons() -> void:
	for item: Button in buttons:
		item.disabled = false
