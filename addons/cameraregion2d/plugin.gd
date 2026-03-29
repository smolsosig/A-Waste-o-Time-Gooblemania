@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("CameraRegionController2D", "Node2D", load("res://addons/cameraregion2d/CameraRegionController2D.gd"), load("res://addons/cameraregion2d/icons/CameraRegionController2D.svg"))
	add_custom_type("CameraRegion2D", "Node2D", load("res://addons/cameraregion2d/CameraRegion2D.gd"), load("res://addons/cameraregion2d/icons/CameraRegion2D.svg"))
	add_custom_type("CameraTransition", "Resource", load("res://addons/cameraregion2d/CameraTransition.gd"), load("res://addons/cameraregion2d/icons/CameraTransition.svg"))


func _exit_tree() -> void:
	remove_custom_type("CameraRegionController2D")
	remove_custom_type("CameraRegion2D")
	remove_custom_type("CameraTransition")
