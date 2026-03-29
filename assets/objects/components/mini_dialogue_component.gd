@tool
@icon("res://assets/misc/tools/icons/MiniDialogueComponent.png")
class_name MiniDialogueComponent extends CharlieTrigger
## Component that displays tiny "mini-dialogue" when Charlie enters the area.
##
## ## [b]DO NOT ADD BY ITSELF!!![/b] Use the [code]mini_dialogue_component.tscn[/code] scene found in
## [code]res://assets/objects/components/mini_dialogue_component.tscn[/code].

## The key for the dialogue this will display.[br][br]
## Do not include the "_rand" part of the key for random dialogue! E.g. "npc_talkie", not "npc_talkie_rand".
@export var dialogue_key: String
## 
@export var random_dialogue_count: int
@onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var dialogue_text: RichTextLabel = get_node("Panel/DialogueText")

var rand_list: Array
var rand_list_duplicate: Array

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	
	anim_player.play("RESET")
	get_node("Placeholder").hide()
	if !dialogue_key:
		print("MiniDialogueComponent (%s) is missing dialogue_key and will therefore not do nuthin'!" % self)
	
	# for whatever fucking reason this stupid piece of shit decided to just. not
	# work all of a sudden. I have to force it to wait for a little while before
	# it returns the needed dialogue. this is, yknow, after working completely
	# fine without it prior? all i did was just write wiki pages.
	#
	# i hate this. this frustrates me. fuck you i hate this engine
	await get_tree().create_timer(0.05).timeout
	
	if !random_dialogue_count:
		dialogue_text.text = Staglobals.return_dialogue(dialogue_key)
	else:
		for num: int in random_dialogue_count:
			num += 1
			rand_list.push_back(num)
		_shake_shuffle_and_roll()

func _shake_shuffle_and_roll() -> void:
	rand_list_duplicate = rand_list.duplicate()
	rand_list_duplicate.shuffle()

func _on_area_entered(area: Area2D) -> void:
	super(area)
	if area is CharlieDetectableComponent:
		if random_dialogue_count:
			if !rand_list_duplicate:
				_shake_shuffle_and_roll()
			var dialogue_key_new: String = "%s_rand%s" % [dialogue_key, rand_list_duplicate[rand_list_duplicate.size()-1]]
			rand_list_duplicate.pop_back()
			dialogue_text.text = Staglobals.return_dialogue(dialogue_key_new)
			
		anim_player.play("show")

func _on_area_exited(area: Area2D) -> void:
	super(area)
	if area is CharlieDetectableComponent:
		anim_player.play("hide")
