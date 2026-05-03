extends Node

@export var debug: bool = false

@export var charlie: CharacterBody2D
var collect_charlie_position: bool = false
@export var marker: Marker2D

@export var max_waves: int = 6
@export var waves_to_begin_second: int = 3
@export var available_positions: Array[Marker2D]

@export var laser_goobles: Array[CharacterBody2D]
@export var rpg_goobles: Array[CharacterBody2D]

var _laser_goobles: Array[CharacterBody2D]
var _rpg_goobles: Array[CharacterBody2D]
var _available_positions: Array[Marker2D]
var selected_goobles: Array[CharacterBody2D]

@onready var cooldown: Timer = $Cooldown

signal stop_internal
signal stop

var routine_1: Array[Array] = [["laser"], ["rpg"], ["laser", "rpg"], ["rpg", "rpg"]]
var routine_2: Array[Array] = [["rpg", "rpg", "laser"], ["rpg", "rpg"], ["rpg", "rpg", "rpg"], ["laser", "rpg", "rpg", "rpg"], ["rpg", "rpg", "rpg", "rpg"], ["rpg", "rpg", "rpg", "rpg", "laser"]]

var tell_player_to_deflect_check: bool = false
signal tell_player_to_deflect

var wave_count: int = 0
var wave_gooble_alive_count: int = 0
var wave_gooble_finished_routine: int = 0:
	set(value):
		if !value:
			finished_routine()
		wave_gooble_finished_routine = value
var routines: Array = []

var do_shit_once: bool = false

func _ready() -> void:
	if debug: start_routine()
	SignalBus.connect("reset", _reset)
	do_shit_once = false

func _reset() -> void:
	cooldown.stop()
	tell_player_to_deflect_check = false

func start_routine() -> void:
	pick_routine()

func pick_routine() -> void:
	if !routines:
		routines = routine_1.duplicate_deep() if wave_count <= waves_to_begin_second else routine_2.duplicate_deep()
		routines.shuffle()
	print("ALERT! New routines selected... (%s)" % str(routines))
	parse_routines(routines.pop_front())

func refill_goobles() -> void:
	_laser_goobles = laser_goobles.duplicate(true)
	_rpg_goobles = rpg_goobles.duplicate(true)
	_available_positions = available_positions.duplicate()
	_laser_goobles.shuffle()
	_rpg_goobles.shuffle()
	_available_positions.shuffle()
	selected_goobles = []

func parse_routines(new_routine: Array) -> void:
	refill_goobles()
	
	for i in new_routine.size():
		var gooble: String = new_routine.pop_front()
		if gooble == "laser": selected_goobles.push_back(_laser_goobles.pop_front())
		if gooble == "rpg": selected_goobles.push_back(_rpg_goobles.pop_front())
	
	for goobles: CharacterBody2D in selected_goobles:
		goobles.start_routine(_available_positions.pop_front())
	
	wave_gooble_alive_count = selected_goobles.size()
	wave_gooble_finished_routine = selected_goobles.size()
	
	print("AND OUR UNWITTING GOOBLE(S): %s" % str(selected_goobles))

func finished_routine() -> void:
	if !wave_gooble_alive_count:
		wave_count += 1
		print("Well done, Charlie! (WAVE CLEARED)")
	
	if wave_count == waves_to_begin_second + 1 && !do_shit_once:
		$Siren.play()
		routines = routine_2.duplicate_deep()
		routines.shuffle()
		do_shit_once = true
	
	if wave_count > max_waves:
		print("### AIR RAID OVER! IT'S DONE! CONGRATULATIONS, CHARLIE! (ALL WAVES CLEARED) #####")
		emit_signal("stop_internal")
		$End.play("end")
		PlayerVar.target_health = PlayerVar.base_health
		PlayerVar.health_speed = 0.1
		return
	
	print("FINISHED WAVE! Wave count: %s/%s. Alive: %s, Finished: %s" % [wave_count, max_waves, wave_gooble_alive_count, wave_gooble_finished_routine])
	cooldown.start()
	print("Starting cooldown timer...")

func _on_cooldown_timeout() -> void:
	print("Selecting new routine...")
	pick_routine()

func _on_game_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "end": emit_signal("stop")
