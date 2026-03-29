extends CharlieState

@export var spin_factor: int = 2
@export var shuri_cooldown: Timer
@export var air_trail: Line2D

@export_group("Attack Component")
@export var attack_component: CharlieAttackComponent
@export var ground_hitbox1: CollisionShape2D
@export var ground_hitbox2: CollisionShape2D
@export var air_hitbox: CollisionShape2D

@export_group("States")
@export var ground_state: CharlieState
@export var air_state: CharlieState

var bat_swing: AudioStreamOggVorbis = preload("res://assets/objects/charlie/sounds/bat_swing.ogg")
var bat_swing_air: AudioStreamOggVorbis = preload("res://assets/objects/charlie/sounds/bat_swing_air.ogg")

@onready var shuriken_scn: PackedScene = preload("res://assets/objects/charlie/secon/shuriken.scn")

func on_enter() -> void:
	attack_component.monitoring = true
	
	if charlie.is_on_floor():
		air_trail.run = false
	else:
		air_trail.run = true
	
	if PlayerVar.melee:
		if charlie.is_on_floor():
			anim_player.play("prim_ground")
			SoundManager.play_sound(bat_swing)
		else:
			anim_player.play("prim_midair")
			SoundManager.play_sound(bat_swing_air)
	else:
		shuri_cooldown.start()
		if charlie.is_on_floor():
			anim_player.play("secon_ground")
		else:
			anim_player.play("secon_midair")
			SoundManager.play_sound(bat_swing_air)
		get_node("%ShurikenBatSFX").play()
		shuriken_spawn()

func state_process(delta : float) -> void:
	if charlie.is_on_floor():
		if charlie.get_floor_normal().x != 0:
			ground_hitbox2.scale.y = 1.5
		else:
			ground_hitbox2.scale.y = 1
	
	if anim_player.current_animation == "prim_midair" || \
	anim_player.current_animation == "secon_midair":
		sprite.spin(delta * spin_factor)
	

# sometimes the player might suddenly switch directions as Charlie is about
# to attack while on ground, thus her atk hitboxes don't match her anims. this
# func is called mid-anim twice to ensure that they're aligned :P
func check_position() -> void:
	if sprite.flip_h:
		ground_hitbox2.position.x = -62
	else:
		ground_hitbox2.position.x = 62

func _on_animation_player_animation_finished(anim_name : String) -> void:
	match anim_name:
		"prim_ground", "prim_midair", "secon_ground", "secon_midair":
			do_something()

func do_something() -> void:
	if charlie.is_on_floor():
		next_state = ground_state
		sprite.stop_spinning()
	else:
		next_state = air_state

func on_exit() -> void:
	# this is to ensure any interruptions don't cause these to break
	ground_hitbox1.set_deferred("disabled", true)
	ground_hitbox2.set_deferred("disabled", true)
	air_hitbox.set_deferred("disabled", true)
	sprite.offset.y = 0 # who knows!

func special_jump() -> void:
	if !charlie.is_on_floor():
		charlie.special_jump()
		next_state = air_state

func shuriken_spawn() -> void:
	var shuriken: Node = shuriken_scn.instantiate()
	
	shuriken.init_position = charlie.global_position
	
	charlie.get_parent().get_parent().add_child(shuriken)
