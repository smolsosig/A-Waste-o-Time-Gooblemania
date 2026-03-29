extends Node
class_name SequenceManagerComponent

# Sequences are when you need to do a sequence of things so something can
# happen. For example: kill X enemies. Find X levers. Maybe even go through
# the right sequence of paths. All that to usually open a door or whatever.

var num : int = 0
var required_num : int = 0
var event_name : String = ""

signal sequence_finished

func _ready() -> void:
	SignalBus.connect("reset", reset)
	required_num = get_parent().required_num
	event_name = get_parent().event_name
	if !required_num:
		push_error("SequenceManagerComponent parent has no required_num export var. Did you forget?")

# The reason it has to get these values from the PARENT instead of having some
# stupidass @export var directly in this node is because there could be one door
# that requires two levers to open and another that requires THREE to open, all
# in the same level. The values of these vars are uneditable when viewing the
# stage scene!!!!!!!!!!

func add_num() -> void:
	num += 1
	if num == required_num:
		emit_signal("sequence_finished")
		SignalBus.emit_signal("event_finished", event_name)
		await get_tree().create_timer(0.2).timeout
		MusicManager.play_jingle("sequence_complete.ogg")

# USAGE INSTRUCTIONS
# 1. Attach this component to the "reward" of your sequence, e.g. a door
# 2. Set "required_num" and "event_name" in this component's parent
# 3. We want three levers to open this door, so create three Hittables and
# type in "@export seq_manager" to hook to the reward
# 4. When the lever is hit, simply call "seq_manager.seq_finished()".
# 5. Back to this node's parent, type "3" in required_num so only 3 levers are
# needed to open the door.

# Here's a (not really) fun fact: AWoT sequences used to be called OBJECTIVES.
# This was because I just thought it was a series of OBJECTIVES you had to do.
# Then I played Quake 1. And Quake called it "sequences". God, sequences sounded
# a lot better and was a lot more accurate on what this sort of thing was.

func reset() -> void:
	num = 0
