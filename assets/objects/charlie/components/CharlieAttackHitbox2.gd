extends Area2D
class_name CharlieAttackComponent2
# This is mainly for the throwing stars

var dont_disappear: bool = false

func _on_area_entered(area: Area2D) -> void:
	if area is EnemyHurtboxComponent:
		dont_disappear = true
		area.damage(PlayerVar.atk_rng(false), PlayerVar.crit)
	
	get_node("%SFX").play()
	if get_node("%DamageTimer").is_stopped:
		get_node("%SFXTimer").start()
