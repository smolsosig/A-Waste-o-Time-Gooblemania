@icon("res://assets/misc/tools/icons/InteractableComponent.png")
extends Node2D

var action_name: StringName

@onready var bubble: Sprite2D = get_node("%Bubble")
@onready var anim_player: AnimationPlayer = get_node("%AnimationPlayer")
@onready var action_name_label: Label = get_node("%ActionName")
@onready var icon_rect: TextureRect = get_node("%IconRect")

var speech_bub: Resource = load("res://assets/ui/object_prompt/speechbub.png")
var interact_bub: Resource = load("res://assets/ui/object_prompt/interactbub.png")

func _ready() -> void:
	bubble.visible = false

func _process(_delta: float) -> void:
	if visible:
		icon_rect.action_name = action_name

func appear(action_desc: String = "interact", action: bool = true) -> void:
	action_name_label.text = action_desc
	
	if action:
		bubble.texture = interact_bub
	else:
		bubble.texture = speech_bub
	
	bubble.visible = true
	anim_player.play("appear")

func disappear() -> void:
	anim_player.play("disappear")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "appear":
		anim_player.play("idle")
	if anim_name == "disappear":
		bubble.visible = false
