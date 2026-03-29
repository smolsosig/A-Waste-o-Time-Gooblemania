extends RigidBody2D

var sfx: AudioStreamPlayer2D
var speed: float = 0
var before_speed: float = 0

var init_position: Vector2
var init_rotation: float

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1
	sfx = get_node("AudioStreamPlayer2D")
	connect("body_entered", _on_body_entered)
	SignalBus.connect("reset", _reset)
	init_position = global_position
	init_rotation = global_rotation

func _reset() -> void:
	global_position = init_position
	global_rotation = init_rotation

func _physics_process(_delta: float) -> void:
	speed = linear_velocity.length()
	sfx.volume_db = clamp(remap(linear_velocity.length(), 0, 1000, 0, 5), 0, 5)

func _on_body_entered(_body: Node) -> void:
	sfx.play()
