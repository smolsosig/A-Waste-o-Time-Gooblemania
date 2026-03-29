class_name GameSprite2D extends Sprite2D
## Sprite2D that resets when Charlie herself resets.

@onready var _visible_on_start: bool = visible

func _ready() -> void:
	SignalBus.connect("reset", _reset)

func _reset() -> void:
	visible = _visible_on_start
