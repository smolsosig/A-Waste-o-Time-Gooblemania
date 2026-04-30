extends CanvasLayer

signal paused
signal unpaused
signal retry
signal quit
var quit_fucking_up_my_pause_menu: bool = false
var pause_on: bool = false
var can_unpause: bool = true

@export var options_menu: CanvasLayer
@export var anim_player: AnimationPlayer
@export var debug: bool = false

@onready var main_buttons: Array = [%Resume, %Retry, %Options, %Exit]

func _ready() -> void:
	if !debug:
		hide()
	else:
		show_pause()
	
	#if !OS.has_feature("pc"):
		#main_buttons[2].hide()
	
	Staglobals.connect("stage_name_changed", stage_name_changed)

func stage_name_changed(stage_name: String) -> void:
	%StageName.text = stage_name.to_upper()

func show_pause() -> void:
	anim_player.play("RESET")
	show()
	anim_player.play("show")
	emit_signal("paused")
	quit_fucking_up_my_pause_menu = true

func hide_pause() -> void:
	emit_signal("unpaused")
	anim_player.play_backwards("show")

# TODO check if in-game, or only running a specific scene, by checking SignalBus.game_mode == 2
# if not, we just pause the game outright and wait for the dev to unpause the game
# otherwise, run the pause menu as usual

func _on_resume_pressed() -> void:
	hide_pause()

func _on_retry_pressed() -> void:
	anim_player.play("show-retry")

func _on_retry_nvm_pressed() -> void:
	anim_player.play_backwards("show-retry")
	main_buttons[1].grab_focus()

func _on_retry_button_pressed() -> void:
	anim_player.play("retry-speeddisc")
	%RetryVBox.focus_behavior_recursive = 0
	%RetryVBox.mouse_behavior_recursive = 0
	can_unpause = false
	Staglobals.current_spawn = 0
	SoundManager.stop_music()
	MusicManager.stop_soundscapes()
	SoundManager.play_ui_sound(load("res://assets/sounds/level_manager/level_restart.ogg"))
	await Fade.fade_out(1.05, Color.BLACK, "Special").finished
	hide()
	get_tree().paused = false
	SignalBus.emit_signal("reset")
	can_unpause = true

func _on_options_pressed() -> void:
	can_unpause = false
	%MainVbox.focus_behavior_recursive = 1
	%MainVbox.mouse_behavior_recursive = 1
	options_menu.show_menu()

func _on_options_menu_options_closed() -> void:
	can_unpause = true
	%MainVbox.focus_behavior_recursive = 2
	%MainVbox.mouse_behavior_recursive = 2
	main_buttons[2].grab_focus()

func _on_exit_pressed() -> void:
	anim_player.play("show-quit")

func _on_quit_nvm_pressed() -> void:
	anim_player.play_backwards("show-quit")

func _on_quit_button_pressed() -> void:
	can_unpause = false
	SignalBus.emit_signal("quit_game")
