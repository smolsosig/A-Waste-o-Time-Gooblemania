@tool
@icon("res://assets/misc/tools/icons/CharlieTrigger.png")
class_name CharlieTrigger extends Area2D
## An [code]Area2D[/code] which responds to Charlie's presence.
##
## Charlie goes in, some triggers get emitted. Charlie goes out, other triggers get emitted.[br]
## The possibilities are endless... though you'll mostly just be calling [code]play()[/code] to [code]GameAnimationPlayer[/code]s.

@export_tool_button("Add Collider", "Add") var button: Callable = _create_collider

## If [code]false[/code], disables trigger on startup. Equivalent to setting [code]monitoring[/code] to [code]false[/code].
## Disabling this will require the trigger to be manually reenabled by calling the trigger's [code]enable_monitoring()[/code]
## method or setting the trigger's [code]monitored[/code]
## property to [code]true[/code].
@export var enable_on_start: bool = true
## Seconds before any/all [code]area_entered[/code] outputs are fired,
## regardless if any output has a delay set.[br][br]
## If value is not zero, trigger will call [code]do_shit_before()[/code] and
## then set off the timer. Important if the trigger script was extended.
@export var delay_before_playing: float
## If [code]true[/code], trigger can be fired multiple times. Leave as
## [code]false[/code] for one-time triggers.
@export var repeatable: bool = false
## If [code]true[/code], trigger does [b]NOT[/b] reset when the level is reset
## via [code]SignalBus.emit_signal("reset")[/code] (which includes dying, and
## resetting via the pause menu). Reloading the level entirely is the only way
## to reset the trigger.[br][br]Positively [b]only set this to [code]true[/code]
## if you've planned everything ahead.[/b] I hope you know what you're doing.
@export var persistent: bool = false
@export_group("Outputs")
## The complete list of outputs this CharlieTrigger will emit.
@export var outputs: Array[Output]

signal charlie_entered
signal charlie_exited

## Outputs to fire when Charlie enters the trigger. This is automatically appended.
var on_enter_outputs: Array
## Outputs to fire when Charlie exits the trigger. This is automatically appended.
var on_exit_outputs: Array

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, true)
	
	set_deferred("monitorable", false)
	set_deferred("monitoring", enable_on_start)
	
	if Engine.is_editor_hint():
		return
	
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)
	
	SignalBus.connect("reset", _reset)
	
	if outputs:
		for _output: Output in outputs:
			assert(_output.output, "%s: Missing output." % name)
			assert(_output.target, "%s: Missing target." % name)
			assert(_output.target_method, "%s: Missing target method." % name)
			if _output.output == "area_entered":
				on_enter_outputs.append(_output)
			elif _output.output == "area_exited":
				on_exit_outputs.append(_output)

func _create_collider() -> void:
	var new_collider: CollisionShape2D = CollisionShape2D.new()
	new_collider.shape = RectangleShape2D.new()
	new_collider.shape.size = Vector2(30, 200)
	new_collider.debug_color = Color(1.0, 0.498, 0.0, 0.42)
	
	add_child(new_collider)
	new_collider.owner = get_tree().edited_scene_root

func _reset() -> void:
	## we do it this way rather than just not connecting if persistent so that
	## some triggers can be triggered over and over again at first and then
	## totally just. not triggerable again. like bosses for example
	if !persistent:
		set_deferred("monitoring", enable_on_start)

func _on_area_entered(area: Area2D) -> void:
	if area is CharlieDetectableComponent:
		if !repeatable:
			set_deferred("monitoring", false)
		
		if delay_before_playing:
			do_shit_before()
			await get_tree().create_timer(delay_before_playing).timeout
			if on_enter_outputs:
				_emit_outputs(on_enter_outputs)
		else:
			if on_enter_outputs:
				_emit_outputs(on_enter_outputs)
		do_shit()
		emit_signal("charlie_entered")

func _on_area_exited(area: Area2D) -> void:
	if area is CharlieDetectableComponent:
		_emit_outputs(on_exit_outputs)
		emit_signal("charlie_exited")

func _emit_outputs(_outputs: Array) -> void:
	var num: int = 0
	for n: Output in _outputs:
		var target: Node = get_node(_outputs[num].target)
		var target_method: StringName = _outputs[num].target_method
		var arguments: Array = _outputs[num].arguments
		var delay: float = _outputs[num].delay
		
		if !delay:
			_emit_output(target, target_method, arguments)
		else:
			var timer: SceneTreeTimer = get_tree().create_timer(delay)
			timer.timeout.connect(func() -> void: _emit_delayed_output(num))
		
		num += 1

func _emit_output(target: Node, target_method: StringName, arguments: Array) -> void:
		if target.has_method(target_method):
			if !arguments:
				if target is not LevelInit:
					target.call(target_method)
				else:
					SoundManager.play_ui_sound(load("res://assets/sounds/ui/ur_a_fuckin_idiot.ogg"))
					push_warning("%s: Tried to call a nothingburger on the SignalBus? What? What the hell are you doing?" % name)
			else:
				# nevermind
				target.callv(target_method, arguments)
		else:
			SoundManager.play_ui_sound(load("res://assets/sounds/ui/ur_a_fuckin_idiot.ogg"))
			if !arguments:
				push_warning("%s: Attempted to call non-existent method \"%s\" on %s, ignoring. If you see this, yell at the level designer." % [name, target_method, target])
			else:
				push_warning("%s: Attempted to call non-existent method \"%s\" with args \"%s\" on %s, ignoring. If you see this, yell at the level designer." % [name, target_method, arguments, target])
		
		

func _emit_delayed_output(num: int) -> void:
	var target: Node = get_node(outputs[num].target)
	var target_method: StringName = outputs[num].target_method
	var arguments: Array = outputs[num].arguments
	
	_emit_output(target, target_method, arguments)

## Enables or disables monitoring on the trigger. This is just a more convient way of writing [code]set_deferred("monitoring", true)[/code].
func enable_monitoring(enable: bool = true) -> void:
	set_deferred("monitoring", enable)

## Extendable method. Anything under this method will be called if Charlie enters the trigger.
func do_shit() -> void:
	pass

## Extendable method. If [code]delay_before_playing[/code], this method is called.
## Note that this does not get called if [code]delay_before_playing[/code] is equals to zero.
func do_shit_before() -> void:
	pass
