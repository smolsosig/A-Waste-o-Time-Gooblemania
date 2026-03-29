extends CharlieState

@export var ground_state: CharlieState
@export var air_state: CharlieState
@export var timer: GameTimer

@export var thing1: Area2D
@export var thing2: Area2D

@onready var start_anims: AnimationLibrary = load("res://assets/objects/charlie/start_anims.res")

func on_enter() -> void:
	ground_state.ok_i_can_actually_jump_now = false
	
	if Staglobals.current_spawn_anim == "null":
		var random_anim_rng: int = randi() % start_anims.get_animation_list_size()
		var random_anim_list: Array = start_anims.get_animation_list()
		var chosen_anim: String
		chosen_anim = "start/%s" % random_anim_list[random_anim_rng]
		anim_player.play(chosen_anim)
	else:
		anim_player.play(Staglobals.current_spawn_anim)
	timer.start()

func unfreeze() -> void:
	next_state = ground_state
	get_node("NoJumpy").start()

func on_exit() -> void:
	thing1.set_deferred("monitorable", true)
	thing2.set_deferred("monitorable", true)

# waiting for the animation to end before continuing turned out to be a massive flaw
# so now we just run a timer so it ends reliably
func _on_game_timer_timeout() -> void:
	unfreeze()
	charlie.open_zoom_end()
	SignalBus.emit_signal("set_pausable", true)
