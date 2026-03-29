@icon("res://assets/misc/tools/icons/pushtrigger.png")
class_name PushTrigger extends Area2D
## An Area2D that pushes any [code]CharacterBody2D[/code] and [code]RigidBody2D[/code] nodes in it.

## The force to exert on the poor little thing that enters this trigger.
@export var force: Vector2 = Vector2(10, 0)
## If [code]true[/code], causes Charlie to jump once when she enters this trigger.
@export var charlie_jumps: bool = false
var shit_in_me: Array
var has_jumped: bool = false

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	set_collision_layer(0)
	set_collision_mask(0)
	set_collision_mask_value(2,true)
	set_collision_mask_value(3,true)

func _physics_process(_delta: float) -> void:
	if shit_in_me:
		for body: Node2D in shit_in_me:
			if body is CharacterBody2D:
					body.move_and_collide(force)
					if charlie_jumps:
						if body.has_method("jump") && !has_jumped:
							body.jump(false)
							has_jumped = true
			elif body is RigidBody2D:
					body.move_and_collide(force)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("jump"):
		has_jumped = false
	shit_in_me.append(body)

func _on_body_exited(body: Node2D) -> void:
	if shit_in_me.has(body):
		shit_in_me.erase(body)
