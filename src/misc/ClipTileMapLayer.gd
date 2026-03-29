class_name ClipTileMapLayer extends TileMapLayer
## [TileMapLayer] meant for clip tiles. When the game runs, it turns itself transparent.

func _ready() -> void:
	modulate = Color.TRANSPARENT
