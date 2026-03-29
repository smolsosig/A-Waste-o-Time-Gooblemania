@tool
extends ColorRect

var interacted: bool = false
@export var door_group: Node2D
var doors: Array
@export_enum("Blue", "Green", "Yellow", "Red") var color_open: String = "Blue":
	set(new_value):
		match new_value:
			"Blue":
				color = Color(0.216, 0.651, 1.0, 1.0)
				get_node("%Label").text = "i open blue doors!!!"
			"Green":
				color = Color(0.051, 0.762, 0.245, 1.0)
				get_node("%Label").text = "i open green doors!!!"
			"Yellow":
				color = Color(0.926, 0.842, 0.156, 1.0)
				get_node("%Label").text = "i open yellow doors!!!"
			"Red":
				color = Color(0.785, 0.138, 0.071, 1.0)
				get_node("%Label").text = "i open red doors!!!"
		color_open = new_value

@onready var area2d: Area2D = get_node("Area2D")

func _ready() -> void:
	if !Engine.is_editor_hint():
		for door: StaticBody2D in door_group.get_children():
			if door.color == color_open:
				doors.append(door)

func _on_area_2d_interacted() -> void:
	for door: Node2D in doors:
		door.open_motherfucker()
	color = Color.BLACK
	get_node("Label").text = "DOORS OPEN!!! NOW GO"
	if !interacted:
		interacted = true
		SoundManager.play_ui_sound(load("res://assets/sounds/ui/sequence_partially_finished.ogg"))
		await get_tree().create_timer(0.5).timeout
		SoundManager.play_ui_sound(load("res://assets/sounds/ui/sequence_complete.ogg"))
