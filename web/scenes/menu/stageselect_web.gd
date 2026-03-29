extends Node2D

@export var camera: Camera2D
@export var smoothing_speed: float = 6.5
@export var target_y_loc: float = 540.0

var music1: AudioStream = preload("res://assets/sounds/music/titlemusic.ogg")
var music2: AudioStream = preload("res://assets/sounds/music/spy_b_reprise.ogg")
var await_input: bool = false
var pressed_key: bool = false

func _ready() -> void:
	SoundManager.play_music(music1)
	camera.global_position.y = -1080
	await get_tree().create_timer(1).timeout
	await_input = true

func _process(delta: float) -> void:
	if Input.is_anything_pressed() && await_input:
		if !pressed_key:
			pressed_key = true
			_change_music()
	
	if pressed_key && camera.global_position.y != target_y_loc:
		camera.global_position.y = lerp(camera.global_position.y, target_y_loc, smoothing_speed * delta)

func _change_music() -> void:
	SoundManager.play_music(music2)


func _on_button_pressed() -> void:
	SignalBus.emit_signal("level_load", "tutorial")

func _on_gooble_pressed() -> void:
	SignalBus.emit_signal("level_load", "gooblemania_a-opening")
