extends CanvasLayer

func _ready() -> void:
	SignalBus.connect("reset", _reset)
	_reset()
	
func _reset() -> void:
	hide()

func start_intermission() -> void:
	show()
