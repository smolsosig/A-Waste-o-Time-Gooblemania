@icon("res://assets/misc/tools/icons/wibling.png")
class_name EnemyMoneyComponent extends Area2D
## An Area2D for spawning Wiblings (money).
# literally the only fucking reason why this is an area 2d is to push shit away

## Input the amount of money this enemy will drop. It will be automatically divided.
@export var money: int = 10
## If [code]true[/code], makes it look like the enemy exploded with cash.
@export var push_money_away: bool = true
## Only applicable when [code]push_money_away[/code] is set to [code]true[/code], this sets how powerful the "explosion" is.
@export var set_force: int = 2000
## Reference a [code]EnemyHealthComponent[/code] to automatically drop money upon death.
@export var health_comp: EnemyHealthComponent
var current_force: int = 0

# we use an array to increase/decrease the probability of some divisions (e.g. 20)
# so we don't end up with multiple WIB 1's on the ground in lieu of a WIB 20
var money_divisions: Array = [1, 5, 5, 20, 20, 20, 20]
var divided_money: Array = []

@onready var wibling_tscn: PackedScene = load("res://assets/objects/wiblings/wibling.tscn")
@onready var timer: Timer = $Timer
@onready var colshape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# In case we randomly decide to give this enemy more/less money for wtv reason
	if get_parent().has_method("money"):
		money = get_parent().money
	
	if health_comp:
		health_comp.connect("died", spawn_money)
	
	current_force = 0

func _physics_process(_delta: float) -> void:
	if push_money_away:
		for body in get_overlapping_bodies():
			if body is WiblingBody:
				var force: Vector2 = (body.global_position - global_position).normalized()
				force *= current_force
				body.apply_central_impulse(force)

func spawn_money() -> void:
	divided_money = money_calculator()
	while divided_money:
		auto_max_money_count(divided_money[0])
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		var wibling: Node = wibling_tscn.instantiate()
		
		wibling.value = divided_money[divided_money.size() - 1]
		wibling.is_non_enemy_money = true
		wibling.global_position.y = global_position.y + rng.randf_range(-10, -30)
		wibling.global_position.x = global_position.x + rng.randf_range(-10, 10)
		wibling.linear_velocity.y = -500
		wibling.angular_velocity = rng.randf_range(-30, 30)
		get_parent().get_parent().call_deferred("add_child", wibling)
		
		divided_money.pop_back()
	
	if push_money_away:
		current_force = set_force
		colshape.position.y = 100
		timer.start()

# if automatic wibling count enabled, adds self to required money needed
func auto_max_money_count(value: int) -> void:
	if Staglobals.ideal_wibl_auto:
		Staglobals.ideal_wibl += value

func money_calculator() -> Array:
	var return_divisions: Array = []
	var temp_money: int = money
	
	while temp_money:
		money_divisions.shuffle()
		if money_divisions.back() > temp_money:
			continue
		else:
			temp_money -= money_divisions.back()
			return_divisions.push_back(money_divisions.back())
	
	return return_divisions

func _on_timer_timeout() -> void:
	colshape.position.y = 0
	current_force = 0
