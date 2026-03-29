extends Line2D

@export_category('Trail')
@export var lengthy: = 10
@export var run: bool = true:
	set(value):
		if value && !run:
			clear_points()
			modulate = Color.WHITE
		run = value

@onready var parent : Node2D = get_parent()
var offset: = Vector2.ZERO

func _ready() -> void:
	SignalBus.connect("charlie_change_pos", change_pos)
	offset = position
	top_level = true

func _physics_process(_delta: float) -> void:
	if run:
		global_position = Vector2.ZERO

		var point: = parent.global_position + offset
		add_point(point, 0)
		
		if get_point_count() > lengthy:
			remove_point(get_point_count() - 1)
	else:
		if get_point_count() != 0:
			remove_point(get_point_count() - 1)

func stop_showing() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)

func change_pos(_i: Vector2, _2: bool) -> void:
	var temp_run: bool = run
	run = false
	clear_points()
	
	await get_tree().create_timer(0.05).timeout
	if temp_run:
		run = true
