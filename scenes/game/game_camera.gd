extends Camera2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

## [b]For debug purposes.[/b] If [code]true[/code], turns off the zoom-in/zoom-out transitions.[br][br]
## [u][b]TURN THIS SHIT BACK ON WHEN YOU'RE DONE DEBUGGING[/b][/u]
@export var no_zooms: bool = false

var charlie: CharacterBody2D

var opening: bool = true
var fading: bool = false
var stage_end_scene: Resource = load("uid://c1t34lmdt6xic")
var slowed_down_because_im_a_retard_who_didnt_plan_this_ahead: bool = false

@onready var level_start_sfx : AudioStreamOggVorbis = load("res://assets/sounds/level_manager/level_start.ogg")

func _ready() -> void:
	SignalBus.connect("cam_shake", cam_shake)
	SignalBus.connect("charlie_door_teleport", c_d_teleport)
	SignalBus.connect("stop_fucking_moving_so_slowly_damn", c_d_teleport)
	SignalBus.connect("stage_end", stage_end)
	SignalBus.connect("charlie_death", death)
	SignalBus.connect("reset", start)
	charlie = get_node("../Charlie")
	
	start()

func start() -> void:
	fading = false
	SignalBus.emit_signal("set_pausable", false)
	SignalBus.emit_signal("stop_cam_please_dawg")
	zoom = Vector2(1.518, 1.518)
	opening = true
	anim_player.speed_scale = 1
	offset.x = 0
	_check_fade_in()
	position_smoothing_enabled = false
	anim_player.play("zoom_out")

# these two methods are immensely unbelievably retarded
func _check_fade_in() -> void:
	if no_zooms: # no_zooms gets top priority
		_fade_in(false)
		return
	elif Staglobals.current_spawn_zoomout: # then the stage setting
		_fade_in()
		return
	else:
		_fade_in(false)
		return

# ts kinda misleading because it means the little iris thing that zooms out
# not the actual camera zooming out motion which the game still does regardless
# but who gives a fuck lmfao
func _fade_in(yeah_fade: bool = true) -> void:
	if yeah_fade:
		Fade.fade_in(2, Color.BLACK, "ZoomIn")
		if Staglobals.current_spawn_zoomout_sfx: SoundManager.play_ui_sound(level_start_sfx)
	else:
		Fade.fade_in(0.05)
		if !Staglobals.current_spawn_zoomout: Staglobals.current_spawn_zoomout = true
# end immensely unbelievably retarded code

func _process(_delta: float) -> void:
	if opening:
		global_position = charlie.global_position

func _on_animation_player_animation_finished(anim_name : String) -> void:
	if anim_name.left(5) == "shake" && slowed_down_because_im_a_retard_who_didnt_plan_this_ahead:
		slowed_down_because_im_a_retard_who_didnt_plan_this_ahead = false
		anim_player.speed_scale = 1

func cam_shake(shake_type: String, normal_speed: bool = false) -> void:
	if !opening && !fading:
		if shake_type:
			anim_player.play("shake_%s" % shake_type)
		else:
			anim_player.play("shake_small")
		
		if normal_speed:
			anim_player.speed_scale = 0.1
			slowed_down_because_im_a_retard_who_didnt_plan_this_ahead = true

func c_d_teleport(_t_position: Vector2 = Vector2.ZERO) -> void:
	position_smoothing_enabled = false
	await get_tree().create_timer(0.05).timeout
	position_smoothing_enabled = true

func stage_end() -> void:
	SignalBus.emit_signal("set_pausable", false)
	var stage_end_inst: CanvasLayer = stage_end_scene.instantiate()
	add_child(stage_end_inst)

func death() -> void:
	anim_player.speed_scale = 1
	global_position = charlie.global_position
	fading = true
	anim_player.play("zoom_in")

func call_zoomout() -> void:
	if !no_zooms: Fade.fade_out(2, Color.BLACK, "ZoomIn", true)

func do_normal_shit_idk() -> void:
	SignalBus.emit_signal("cam_ok_u_can_follow_now")
	SignalBus.emit_signal("set_pausable", true)
	opening = false
