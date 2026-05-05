class_name ClipTileMapLayer extends TileMapLayer
## [TileMapLayer] meant for clip tiles. When the game runs, it turns itself transparent.

func _ready() -> void:
	SignalBus.showhide_clip.connect(showhide_clips)
	showhide_clips()

func showhide_clips(showy: bool = false) -> void:
	if showy: modulate = Color.WHITE
	else: modulate = Color.TRANSPARENT
