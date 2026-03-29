extends AnimatedSprite2D

@export var charlie: CharacterBody2D
@export var turning_speed: float = 10

@export var state_machine: CharlieStateMachine
@export var air_state: CharlieState
@export var attack_state: CharlieState

# there is probably a better way to do this.
# I don't care.
var hurtframes: Array
var hurtframes_full: Array

var init_spin_lock := false
var spin_direction: int

func _ready() -> void:
	init_spin_lock = false
	hurtframes = init_hurtframes_count()
	hurtframes_full = hurtframes.duplicate()
	hurtframes.shuffle()
	SignalBus.connect("reset", reset)

func init_hurtframes_count() -> Array:
	var _array: Array
	var _count: int = 0
	for i in sprite_frames.get_frame_count("hurt"):
		_array.append(_count)
		_count += 1
	return _array

func reset() -> void:
	if flip_h:
		flip_h = false

#region code for rotating charlie
func _process(delta : float) -> void:
	if charlie.is_on_floor():
		if !(state_machine.current_state == attack_state && state_machine.last_state == air_state):
			if position.y != -29: position.y = -29
			if offset.y != -83: offset.y = -83
		
		var floor_normal: float = charlie.get_floor_normal().x
		if rotation != floor_normal:
			rotation = lerp(rotation, floor_normal, 30 * delta)
	else:
		if state_machine.current_state == air_state:
			if position.y != -114: position.y = -114
			if offset.y: offset.y = 0
#endregion

#region spinning code
func spin(delta : float) -> void:
	if !init_spin_lock:
		init_spin()
	else:
		rotation += (turning_speed * spin_direction) * delta

func init_spin() -> void:
	spin_direction = -1 if flip_h else 1
	init_spin_lock = true

func stop_spinning() -> void:
	set_deferred("rotation", 0)
	init_spin_lock = false
#endregion

func rand_hurt_frame() -> void:
	var new_frame: int = hurtframes.pop_front()
	
	if hurtframes.is_empty():
		hurtframes = hurtframes_full.duplicate()
		hurtframes.shuffle()
	
	frame = new_frame

func _on_air_state_double_jumped() -> void:
	turning_speed *= 5
	var tween: Tween = create_tween()
	tween.tween_property(self, "turning_speed", turning_speed * 0.2, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
