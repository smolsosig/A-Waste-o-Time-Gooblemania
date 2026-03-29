@icon("res://assets/misc/tools/icons/hitbox.png")
extends Area2D
class_name CharlieAttackComponent
# This is mainly for the bat LOL

var bat_hit: AudioStreamOggVorbis = load("res://assets/objects/charlie/sounds/bat_hit.ogg")
var dont_disappear: bool = false

signal attacked
@export_enum("Both", "Melee", "Ranged", "None") var damage_type: int = 1
@export_group("Hookables")
@export var atk_state: CharlieState
@export var momentum_window: Timer

func _ready() -> void:
	if damage_type == 1:
		monitoring = false

# NOTE i'm not sure if Charlie's hitbox should disable after attacking an enemy
# 3/15/2025: nah probably not, is too cheesy
func _on_area_entered(area:Area2D) -> void:
	if damage_type == 1:
		if area is EnemyHurtboxComponent:
			if momentum_window.is_stopped():
				area.damage(damage_type, PlayerVar.atk_rng(true), PlayerVar.crit)
			else:
				# guaranteed crit if attacked just after dashing :3
				area.damage(damage_type, PlayerVar.atk_rng(true, true), true)
				NG.medal_unlock(88760)
			
		if area is HittableComponent:
			area.interact()
	
		SoundManager.play_sound_with_pitch(bat_hit, audio_rng())
		
		if area.can_bounce_off_it:
			atk_state.special_jump()
			
	elif damage_type == 2:
		if area is EnemyHurtboxComponent:
			dont_disappear = true
			area.damage(damage_type, PlayerVar.atk_rng(false), PlayerVar.crit)
		
		get_node("%SFX").play()
		if get_node("%DamageTimer").is_stopped:
			get_node("%SFXTimer").start()

func audio_rng() -> float:
	var random:RandomNumberGenerator = RandomNumberGenerator.new()
	random.randomize()
	return random.randf_range(0.9, 1.1)
