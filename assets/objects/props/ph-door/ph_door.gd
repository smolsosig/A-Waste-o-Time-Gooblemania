extends StaticBody2D
class_name SequenceDoor

@export var required_num : int = 1
@export var event_name : String = "vent_door_open"
@export var start_locked: bool = true

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var seq_man_comp : SequenceManagerComponent = $SequenceManagerComponent
@onready var area2d : Area2D = $Area2D

@onready var finished_sound : AudioStreamPlayer = $AudioStreamPlayer
@onready var lock_sound: AudioStreamOggVorbis = load("res://assets/objects/props/ph-door/door_close.ogg")
@onready var unlock_sound : AudioStreamOggVorbis = load("res://assets/objects/props/ph-door/door_open.ogg")

func _ready() -> void:
	SignalBus.connect("reset", start)
	start()
	
func start() -> void:
	if start_locked:
		anim_player.play("locked")
	else:
		anim_player.play("unlocked")
	area2d.monitoring = false

func seq_finished() -> void:
	seq_man_comp.add_num()

func lock() -> void:
	anim_player.play("locking")
	SoundManager.play_sound(lock_sound, "UI SFX")

func unlock() -> void:
	anim_player.play("wait_unlocked")
	area2d.visible = true
	area2d.monitoring = true

func _on_animation_player_animation_finished(anim_name : String) -> void:
	match anim_name:
		"unlocking":
			anim_player.play("unlocked")
		"locking":
			anim_player.play("locked")

func _on_area_2d_area_entered(area : Area2D) -> void:
	if area is CharlieDetectableComponent:
		anim_player.play("unlocking")
		SoundManager.play_sound(unlock_sound, "UI SFX")
		area2d.set_deferred("monitoring", false)
