@tool
extends StaticBody2D

@export_enum("Blue", "Green", "Yellow", "Red") var color: String = "Blue":
	set(new_value):
		match new_value:
			"Blue":
				get_node("%ColorRect").color = Color(0.216, 0.651, 1.0, 1.0)
			"Green":
				get_node("%ColorRect").color = Color(0.051, 0.762, 0.245, 1.0)
			"Yellow":
				get_node("%ColorRect").color = Color(0.926, 0.842, 0.156, 1.0)
			"Red":
				get_node("%ColorRect").color = Color(0.785, 0.138, 0.071, 1.0)
		color = new_value

func open_motherfucker() -> void:
	hide()
	get_node("CollisionShape2D").set_deferred("disabled", true)
