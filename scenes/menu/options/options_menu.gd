extends CanvasLayer

#region GAME BUTTONS
func _on_show_hud_toggled(toggled_on: bool) -> void:
	PlayerVar.save_setting("game", "show_hud", toggled_on)
	PlayerVar.show_hud = toggled_on
	if toggled_on: %ShowHUD.text = "YEAH"
	else: %ShowHUD.text = "NO"

func _on_cam_shake_toggled(toggled_on: bool) -> void:
	PlayerVar.save_setting("game", "cam_shake", toggled_on)
	PlayerVar.cam_shake = toggled_on
	if toggled_on: %CamShake.text = "RATTLE 'N' ROLL"
	else: %CamShake.text = "KEEP IT CALM"

func _on_wiblings_slider_value_changed(value: float) -> void:
	PlayerVar.save_setting("game", "money_limit", value)
	Staglobals.money_limit = value
#endregion
#region AUDIO SETTINGS
var master_volume: float
var music_volume: float
var sounds_volume: float

func _on_master_slider_value_changed(value: float) -> void:
	master_volume = value
	AudioServer.set_bus_volume_db(0, value)
	PlayerVar.save_setting("audio", "master_volume", value)

func _on_music_slider_value_changed(value: float) -> void:
	music_volume = value
	AudioServer.set_bus_volume_db(1, value)
	PlayerVar.save_setting("audio", "music_volume", value)

func _on_sounds_slider_value_changed(value: float) -> void:
	sounds_volume = value
	AudioServer.set_bus_volume_db(2, value)
	PlayerVar.save_setting("audio", "sounds_volume", value)
#endregion
#region VIDEO SETTINGS
func _on_fps_toggled(toggled_on: bool) -> void:
	SignalBus.emit_signal("show_fps", toggled_on)
	PlayerVar.save_setting("video", "show_fps", toggled_on)
	if !toggled_on:
		%FPS.text = "KEEP IT HIDDEN"
	else:
		%FPS.text = "YEAH, SHOW ME"

func _on_display_mode_toggled(toggled_on: bool) -> void:
	PlayerVar.save_setting("video", "display_mode", toggled_on)
	if toggled_on:
		%DisplayMode.text = "FULLSCREEN"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		%DisplayMode.text = "NOT FULLSCREEN"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_v_sync_toggled(toggled_on: bool) -> void:
	PlayerVar.save_setting("video", "vsync", toggled_on)
	if toggled_on:
		%VSync.text = "ENABLED"
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		%VSync.text = "DISABLED"
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_max_fps_item_selected(index: int) -> void:
	PlayerVar.save_setting("video", "max_fps", index)
	Engine.max_fps = PlayerVar.max_fps[index]
#endregion

#region LOAD 'EM UP
func _ready() -> void:
	%ShowHUD.button_pressed = PlayerVar.return_setting("game", "show_hud")
	%WiblingsSlider.value = PlayerVar.return_setting("game", "money_limit")
	%CamShake.button_pressed = PlayerVar.return_setting("game", "cam_shake")
	
	%MasterSlider.value = PlayerVar.return_setting("audio", "master_volume")
	%MusicSlider.value = PlayerVar.return_setting("audio", "music_volume")
	%SoundsSlider.value = PlayerVar.return_setting("audio", "sounds_volume")
	
	%DisplayMode.button_pressed = PlayerVar.return_setting("video", "display_mode")
	%VSync.button_pressed = PlayerVar.return_setting("video", "vsync")
	%FPS.button_pressed = PlayerVar.return_setting("video", "show_fps")
	%MaxFPS.selected = PlayerVar.return_setting("video", "max_fps")
#endregion

signal options_closed

func show_menu() -> void:
	%OptionsPanel.modulate = Color.TRANSPARENT
	$ColorRect.modulate = Color.TRANSPARENT
	show()
	var tween := create_tween()
	tween.tween_property(%OptionsPanel, "modulate", Color.WHITE, 0.5)
	tween.chain().tween_property($ColorRect, "modulate", Color(1.0, 1.0, 1.0, 0.196), 0.5)
	%OptionsPanel.focus_behavior_recursive = 2
	%OptionsPanel.mouse_behavior_recursive = 2
	%Game.grab_focus()

func _on_save_exit_pressed() -> void:
	%OptionsPanel.focus_behavior_recursive = 1
	%OptionsPanel.mouse_behavior_recursive = 1
	var tween := create_tween()
	tween.tween_property(%OptionsPanel, "modulate", Color.TRANSPARENT, 0.25)
	tween.chain().tween_property($ColorRect, "modulate", Color.TRANSPARENT, 0.25)
	await tween.finished
	emit_signal("options_closed")
	%InputRemap.applyMap()
	hide()
