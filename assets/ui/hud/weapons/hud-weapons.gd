extends Node2D

var weapon_switch_sfx: AudioStreamOggVorbis = load("res://assets/sounds/ui/weapon_select.ogg")

@onready var spinner: Sprite2D = get_node("Spinner")
@onready var timer: Timer = get_node("Timer")
@onready var melee_sprite: Sprite2D = get_node("Spinner/Melee")
@onready var shuri_sprite: Sprite2D = get_node("Spinner/Shuri")

func _ready() -> void:
	PlayerVar.connect("weapon_changed", weapon_changed)
	spinner.position = Vector2(-401.0, 998)

func weapon_changed(melee: bool) -> void:
	timer.start()
	
	if spinner.position.x != -89:
		var tween_pos: Tween = create_tween()
		tween_pos.tween_property(spinner, "position", Vector2(-89, 998), 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
	var tween_rot: Tween = create_tween()
	var rotations: float
	if melee:
		rotations = 0
		PlayerVar.set_cursor(false)
	else:
		rotations = 180
		PlayerVar.set_cursor(true)
	
	tween_rot.tween_property(spinner, "rotation_degrees", rotations, 0.3).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
	
	SoundManager.play_ui_sound(weapon_switch_sfx)

func _on_timer_timeout() -> void:
	if spinner.position.x != -401.0:
		var tween_pos: Tween = create_tween()
		tween_pos.tween_property(spinner, "position", Vector2(-401.0, 998), 0.1)
