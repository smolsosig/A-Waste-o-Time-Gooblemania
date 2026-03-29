extends RigidBody2D
class_name WiblingBody

@export var value: int = 5
@export var anim_player: AnimationPlayer
@export var is_non_enemy_money: bool = false

func _ready() -> void:
	SignalBus.connect("reset", remove_self)
	if is_non_enemy_money:
		Staglobals.money_slots.push_back(self)
		Staglobals.money_slots_size = Staglobals.money_slots.size()
	anim_player.play("cash-%s" % value)
	
	# randomizes anim starting point so it isn't booooriiiiiing
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	if value == 1:
		anim_player.seek(rng.randf_range(0, 0.5))
	else:
		anim_player.seek(rng.randf_range(0, 1))

func remove_self() -> void:
	if Staglobals.money_slots.has(self):
		Staglobals.money_slots.erase(self)
	queue_free()

func _on_body_entered(_body: Node) -> void:
	$AudioStreamPlayer2D.play()
