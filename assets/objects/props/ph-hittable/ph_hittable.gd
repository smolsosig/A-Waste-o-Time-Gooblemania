extends Sprite2D

@onready var sprite1 : Texture2D = load("res://assets/objects/props/ph-hittable/hit1.png")
@onready var sprite2 : Texture2D = load("res://assets/objects/props/ph-hittable/hit2.png")
@export var seq_manager : Node

signal interacted
var interactedd := false

var sound : AudioStreamOggVorbis = load("res://assets/sounds/ui/sequence_partially_finished.ogg")

func _ready() -> void:
	SignalBus.connect("reset", reset)
	texture = sprite1

func _on_area_2d_interacted() -> void:
	emit_signal("interacted")
	if seq_manager:
		seq_manager.seq_finished()
	
	texture = sprite2
	if !interactedd:
		SoundManager.play_sound(sound)

func reset() -> void:
	texture = sprite1
	interactedd = false
