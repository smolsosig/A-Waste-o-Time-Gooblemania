extends Camera2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

## [b]For debug purposes.[/b] If [code]true[/code], turns off the zoom-in/zoom-out transitions.[br][br]
## [u][b]TURN THIS SHIT BACK ON WHEN YOU'RE DONE DEBUGGING[/b][/u]
@export var no_zooms: bool = false

var charlie: CharacterBody2D

var opening: bool = true
var stage_end_scene: Resource = load("uid://c1t34lmdt6xic")
var slowed_down_because_im_a_retard_who_didnt_plan_this_ahead: bool = false

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
	SignalBus.emit_signal("set_pausable", false)
	SignalBus.emit_signal("stop_cam_please_dawg")
	zoom = Vector2(1.518, 1.518)
	opening = true
	anim_player.speed_scale = 1
	offset.x = 0
	if !no_zooms: Fade.fade_in(2, Color.BLACK, "ZoomIn")
	else: Fade.fade_in(0.05)
	drag_vertical_enabled = false
	position_smoothing_enabled = false
	anim_player.play("zoom_out")

func _process(_delta: float) -> void:
	if opening:
		global_position = charlie.global_position

func _on_animation_player_animation_finished(anim_name : String) -> void:
	if anim_name.left(5) == "shake" && slowed_down_because_im_a_retard_who_didnt_plan_this_ahead:
		slowed_down_because_im_a_retard_who_didnt_plan_this_ahead = false
		anim_player.speed_scale = 1

func cam_shake(shake_type: String, normal_speed: bool = false) -> void:
	if shake_type:
		anim_player.play("shake_%s" % shake_type)
	else:
		anim_player.play("shake_small")
	
	if normal_speed:
		anim_player.speed_scale = 0.1
		slowed_down_because_im_a_retard_who_didnt_plan_this_ahead = true

func c_d_teleport(_t_position: Vector2 = Vector2.ZERO) -> void:
	drag_vertical_enabled = false
	position_smoothing_enabled = false
	await get_tree().create_timer(0.05).timeout
	drag_vertical_enabled = true
	position_smoothing_enabled = true

func stage_end() -> void:
	SignalBus.emit_signal("set_pausable", false)
	var stage_end_inst: CanvasLayer = stage_end_scene.instantiate()
	add_child(stage_end_inst)

func death() -> void:
	anim_player.speed_scale = 1
	drag_vertical_enabled = false
	global_position = charlie.global_position
	anim_player.play("zoom_in")

func call_zoomout() -> void:
	if !no_zooms: Fade.fade_out(2, Color.BLACK, "ZoomOut")

func do_normal_shit_idk() -> void:
	opening = false
	SignalBus.emit_signal("cam_ok_u_can_follow_now")
	SignalBus.emit_signal("set_pausable", true)
